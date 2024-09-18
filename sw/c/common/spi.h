// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef SPI_H__
#define SPI_H__

#include "stdint.h"

#define SPI_TX_REG 0
#define SPI_STATUS_REG 4

#define SPI_STATUS_TX_FULL 1 << 0
#define SPI_STATUS_TX_EMPTY 1 << 1
#define SPI_FROM_BASE_ADDR(addr) ((spi_reg_t)(addr))

typedef void *spi_reg_t;

typedef enum {
  spi_status_fifo_full  = SPI_STATUS_TX_FULL,
  spi_status_fifo_empty = SPI_STATUS_TX_EMPTY,
} spi_status_t;

typedef struct spi {
  spi_reg_t reg;
  uint32_t speed;
} spi_t;

void spi_init(spi_t *spi, spi_reg_t reg, uint32_t speed);
void spi_send_byte_blocking(spi_t *spi, char c);
spi_status_t spi_get_status(spi_t *spi);

void spi_wait_idle(spi_t *spi);
void spi_tx(spi_t *spi, const uint8_t *data, uint32_t len);

#endif  // SPI_H__
