use core::ops::Deref;
use fugit::{Hertz, NanosDurationU64};
use ibex_demo_system_pac as pac;

pub struct Timer<T: Deref<Target = pac::timer0::RegisterBlock>> {
    device: T,
    clock_rate: Hertz<u64>,
}

pub struct CountDown<'a, T: Deref<Target = pac::timer0::RegisterBlock>> {
    timer: &'a Timer<T>,
    timeout: Option<u64>,
}

impl<T: Deref<Target = pac::timer0::RegisterBlock>> Timer<T> {
    pub fn new<H>(timer: T, clock_rate: H) -> Self
    where
        H: Into<Hertz<u64>>,
    {
        let mut timer = Self {
            device: timer,
            clock_rate: clock_rate.into(),
        };
        timer.set_counter(0);
        timer.set_cmp(u64::MAX);
        timer
    }

    pub fn new_count_down(&self) -> CountDown<'_, T> {
        CountDown {
            timer: self,
            timeout: None,
        }
    }

    pub fn get_counter(&self) -> u64 {
        let mut timeh;
        let mut timel;
        loop {
            timeh = self.device.mtimeh.read().value().bits();
            timel = self.device.mtimel.read().value().bits();
            if timeh == self.device.mtimeh.read().value().bits() {
                break;
            }
        }
        (timeh as u64) << 32 | (timel as u64)
    }

    pub fn set_cmp(&mut self, value: u64) {
        self.device.mtimecmpl.write(|w| {
            w.value().variant(u32::MAX);
            w
        });
        self.device.mtimecmph.write(|w| {
            w.value().variant((value >> 32) as u32);
            w
        });
        self.device.mtimecmpl.write(|w| {
            w.value().variant((value) as u32);
            w
        });
    }

    pub fn get_cmp(&self) -> u64 {
        let mut comph;
        let mut compl;
        loop {
            comph = self.device.mtimecmph.read().value().bits();
            compl = self.device.mtimecmpl.read().value().bits();
            if comph == self.device.mtimecmph.read().value().bits() {
                break;
            }
        }
        (comph as u64) << 32 | (compl as u64)
    }

    pub fn set_counter(&mut self, value: u64) {
        self.device.mtimel.write(|w| {
            w.value().variant(u32::MAX);
            w
        });
        self.device.mtimeh.write(|w| {
            w.value().variant((value >> 32) as u32);
            w
        });
        self.device.mtimel.write(|w| {
            w.value().variant((value) as u32);
            w
        });
    }
}

/// The timer trait has been removed on the release 1.0.0 of the embedded hal.
/// So, this a temporary copy of the delete traits as suggested [here](https://github.com/rust-embedded/embedded-hal/issues/357).
pub mod timer {
    use nb;
    use void::Void;

    pub trait CountDown {
        type Time;
        fn start<T>(&mut self, count: T)
        where
            T: Into<Self::Time>;
        fn wait(&mut self) -> nb::Result<(), Void>;
    }
    pub trait Cancel: CountDown {
        type Error;
        fn cancel(&mut self) -> Result<(), Self::Error>;
    }
}

impl<U: Deref<Target = pac::timer0::RegisterBlock>> timer::CountDown for CountDown<'_, U> {
    type Time = NanosDurationU64;
    fn start<T>(&mut self, count: T)
    where
        T: Into<Self::Time>,
    {
        let count = count.into().to_nanos();
        let period: NanosDurationU64 = self.timer.clock_rate.into_duration();
        let period = period.to_nanos();

        self.timeout = Some((count / period).wrapping_add(self.timer.get_counter()));
    }

    fn wait(&mut self) -> nb::Result<(), void::Void> {
        let Some(timeout) = self.timeout else {
            panic!("Countdown not started");
        };

        if self.timer.get_counter() < timeout {
            return Err(nb::Error::WouldBlock);
        }
        Ok(())
    }
}

impl<U: Deref<Target = pac::timer0::RegisterBlock>> timer::Cancel for CountDown<'_, U> {
    type Error = super::utils::Error;
    fn cancel(&mut self) -> Result<(), Self::Error> {
        self.timeout = None;
        Ok(())
    }
}
