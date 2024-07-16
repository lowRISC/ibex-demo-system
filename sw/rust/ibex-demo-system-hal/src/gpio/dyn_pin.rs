// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use super::pin::{DisabledState, InputState, OutputState, Pin};
use core::marker::PhantomData;

use embedded_hal::digital::{ErrorType, InputPin, OutputPin, PinState};

pub struct DynPin<S = DisabledState> {
    port: char,
    id: u8,
    _mode: PhantomData<S>,
}

impl<S> DynPin<S> {
    pub fn new(port: char, id: u8) -> Self {
        Self {
            port,
            id,
            _mode: PhantomData,
        }
    }
}

impl<S> Pin for DynPin<S> {
    fn id(&self) -> u8 {
        self.id
    }

    fn port(&self) -> char {
        self.port
    }
}

impl DynPin<DisabledState> {
    pub fn into_input(self) -> DynPin<InputState> {
        DynPin::new(self.port, self.id)
    }

    pub fn into_output(self) -> DynPin<OutputState> {
        DynPin::new(self.port, self.id)
    }
}

impl DynPin<OutputState> {
    pub fn into_input(self) -> DynPin<InputState> {
        DynPin::new(self.port, self.id)
    }
}

impl DynPin<InputState> {
    pub fn into_output(self) -> DynPin<OutputState> {
        DynPin::new(self.port, self.id)
    }
}

impl<T> ErrorType for DynPin<T> {
    type Error = crate::utils::Error;
}

impl OutputPin for DynPin<OutputState> {
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

impl InputPin for DynPin<InputState> {
    fn is_high(&mut self) -> Result<bool, Self::Error> {
        Ok(self.get_value())
    }

    fn is_low(&mut self) -> Result<bool, Self::Error> {
        Ok(!self.get_value())
    }
}
