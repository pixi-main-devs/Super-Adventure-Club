ready_to_read, ready_to_write, in_error = \
               select.select( potential_readers, potential_writers, potential_errs, timeout)

