// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdint.h>
#include "spi.h"
#include "dev_access.h"

typedef struct spi_handle{
    spi_reg_t *reg;
    uint32_t speed;
} spi_handle_t;

void spi_init(spi_t *spi, spi_reg_t *spi_reg, uint32_t speed){
  spi->reg = spi_reg;
  spi->speed = speed;
}

void spi_send_byte_blocking(spi_t *spi, char c) {
  while(spi->reg->status_reg & SPI_STATUS_TX_FULL);
  spi->reg->tx_reg = c;
}

spi_status_t spi_get_status(spi_t *spi){
   return (spi_status_t) spi->reg->status_reg;
}
