`ifndef DEV_MAP_VH
`define DEV_MAP_VH
  `define DEV_MAP__io_ext_bram__BASE 'h40000000
  `define DEV_MAP__io_ext_bram__MASK 'hffff
  `define DEV_MAP__mem__BASE 'h80000000
  `define DEV_MAP__mem__MASK 'h7ffffff
  `define DEV_MAP__io_ext_flash__BASE 'h41000000
  `define DEV_MAP__io_ext_flash__MASK 'hffffff
  `define DEV_MAP__io_int_prci0__BASE 'h3000
  `define DEV_MAP__io_int_prci0__MASK 'hfff
  `define DEV_MAP__io_int_rtc__BASE 'h2000
  `define DEV_MAP__io_int_rtc__MASK 'hfff
  `define DEV_MAP__io_ext_uart__BASE 'h42000000
  `define DEV_MAP__io_ext_uart__MASK 'h1fff
  `define DEV_MAP__io_ext_spi__BASE 'h42002000
  `define DEV_MAP__io_ext_spi__MASK 'h1fff
  `define DEV_MAP__io_int_bootrom__BASE 'h0
  `define DEV_MAP__io_int_bootrom__MASK 'h1fff
`endif // DEV_MAP_VH
