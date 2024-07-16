// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use super::dyn_pin::DynPin;
use super::pin;
use super::pin::{DisabledState, InputState, OutputState, Pin};
use core::marker::PhantomData;

use embedded_hal::digital::{ErrorType, InputPin, OutputPin, PinState};

pub struct StaticPin<const P: char, const N: u8, S = DisabledState> {
    _mode: PhantomData<S>,
}

impl<const P: char, const N: u8, S> StaticPin<P, N, S> {
    pub fn new() -> Self {
        Self { _mode: PhantomData }
    }
}

impl<const P: char, const N: u8, S> pin::Pin for StaticPin<P, N, S> {
    fn id(&self) -> u8 {
        N
    }

    fn port(&self) -> char {
        P
    }
}

impl<const P: char, const N: u8, S> pin::ErasePin for StaticPin<P, N, S> {
    type ErasedPin = DynPin<S>;
    fn erase(self) -> DynPin<S> {
        DynPin::new(P, N)
    }
}

pub struct PortPins<const P: char> {
    pub pin0: StaticPin<P, 0>,
    pub pin1: StaticPin<P, 1>,
    pub pin2: StaticPin<P, 2>,
    pub pin3: StaticPin<P, 3>,
    pub pin4: StaticPin<P, 4>,
    pub pin5: StaticPin<P, 5>,
    pub pin6: StaticPin<P, 6>,
    pub pin7: StaticPin<P, 7>,
    pub pin8: StaticPin<P, 8>,
    pub pin9: StaticPin<P, 9>,
    pub pin10: StaticPin<P, 10>,
    pub pin11: StaticPin<P, 11>,
    pub pin12: StaticPin<P, 12>,
    pub pin13: StaticPin<P, 13>,
    pub pin14: StaticPin<P, 14>,
    pub pin15: StaticPin<P, 15>,
}

impl<const P: char> PortPins<P> {
    pub fn new() -> Self {
        PortPins {
            pin0: StaticPin::<P, 0>::new(),
            pin1: StaticPin::<P, 1>::new(),
            pin2: StaticPin::<P, 2>::new(),
            pin3: StaticPin::<P, 3>::new(),
            pin4: StaticPin::<P, 4>::new(),
            pin5: StaticPin::<P, 5>::new(),
            pin6: StaticPin::<P, 6>::new(),
            pin7: StaticPin::<P, 7>::new(),
            pin8: StaticPin::<P, 8>::new(),
            pin9: StaticPin::<P, 9>::new(),
            pin10: StaticPin::<P, 10>::new(),
            pin11: StaticPin::<P, 11>::new(),
            pin12: StaticPin::<P, 12>::new(),
            pin13: StaticPin::<P, 13>::new(),
            pin14: StaticPin::<P, 14>::new(),
            pin15: StaticPin::<P, 15>::new(),
        }
    }
}

impl<const P: char, const N: u8> StaticPin<P, N, DisabledState> {
    pub fn into_input(self) -> StaticPin<P, N, InputState> {
        // Todo: Configure the pin as Input

        StaticPin::<P, N, InputState>::new()
    }

    pub fn into_output(self) -> StaticPin<P, N, OutputState> {
        // Todo: Configure the pin as Output

        StaticPin::<P, N, OutputState>::new()
    }
}

impl<const P: char, const N: u8> StaticPin<P, N, OutputState> {
    pub fn into_input(self) -> StaticPin<P, N, InputState> {
        // Todo: Configure the pin as Output

        StaticPin::<P, N, InputState>::new()
    }
}

impl<const P: char, const N: u8> StaticPin<P, N, InputState> {
    pub fn into_output(self) -> StaticPin<P, N, OutputState> {
        StaticPin::<P, N, OutputState>::new()
    }
}

impl<const P: char, const N: u8, T> ErrorType for StaticPin<P, N, T> {
    type Error = crate::utils::Error;
}

impl<const P: char, const N: u8> OutputPin for StaticPin<P, N, OutputState> {
    fn set_low(&mut self) -> Result<(), Self::Error> {
        self.set_value(false);
        Ok(())
    }

    fn set_high(&mut self) -> Result<(), Self::Error> {
        self.set_value(true);
        Ok(())
    }

    fn set_state(&mut self, state: PinState) -> Result<(), Self::Error> {
        self.set_value(match state {
            PinState::Low => false,
            PinState::High => true,
        });
        Ok(())
    }
}

impl<const P: char, const N: u8> InputPin for StaticPin<P, N, InputState> {
    #[cfg(feature = "embedded-hal-0-2")]
    type Error = crate::utils::Error;
    fn is_high(&mut self) -> Result<bool, Self::Error> {
        Ok(self.get_value())
    }

    fn is_low(&mut self) -> Result<bool, Self::Error> {
        Ok(!self.get_value())
    }
}
