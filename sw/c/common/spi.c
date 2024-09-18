// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "spi.h"

#include <stdint.h>

#include "dev_access.h"

void spi_init(spi_t *spi, spi_reg_t spi_reg, uint32_t speed) {
  spi->reg   = spi_reg;
  spi->speed = speed;
}

void spi_send_byte_blocking(spi_t *spi, char c) {
  while (DEV_READ(spi->reg + SPI_STATUS_REG) & SPI_STATUS_TX_FULL)
    ;
  DEV_WRITE(spi->reg + SPI_TX_REG, c);
}

spi_status_t spi_get_status(spi_t *spi) { return (spi_status_t)DEV_READ(spi->reg + SPI_STATUS_REG); }

void spi_wait_idle(spi_t *spi) {
  while ((spi_get_status(spi) & spi_status_fifo_empty) != spi_status_fifo_empty);
}

void spi_tx(spi_t *spi, const uint8_t *data, uint32_t len) {
  spi_wait_idle(spi);
  while (len--) {
    spi_send_byte_blocking(spi, *data++);
  }
}
