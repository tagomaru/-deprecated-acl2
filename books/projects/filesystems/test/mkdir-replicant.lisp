(include-book "../test-stuff")
(include-book "oslib/argv" :dir :system)

(b*
    (((mv argv state)
      (oslib::argv))
     ((mv errmsg opts extra-args) (parse-mkdir-opts argv))
     ;; Either a parsing error, or no files provided on the command line.
     ((when (or errmsg (atom extra-args)))
      (mv (good-bye 1) fat32-in-memory state))
     ((mkdir-opts opts) opts)
     ((mv & val state)
      (getenv$ "DISK" state))
     ((mv fat32-in-memory &)
      (disk-image-to-lofat
       fat32-in-memory val state))
     ((mv fs &)
      (lofat-to-hifat fat32-in-memory))
     ((mv fs exit-status)
      ;; The -p option to mkdir is not yet supported.
      (if opts.parents
          (mv fs -1)
        (mkdir-list fs extra-args 0)))
     ((mv fat32-in-memory &)
      (hifat-to-lofat fat32-in-memory fs))
     ((mv & val state)
      (getenv$ "MKDIR_OUTPUT" state))
     ;; Will take the exit status from lofat-to-disk-image later.
     ((mv state &)
      (lofat-to-disk-image
       fat32-in-memory val state)))
  (mv (good-bye exit-status) fat32-in-memory state))
