#include "consumer.h"

#include <gmp.h>

int
gmp_verify_consumer_value(void)
{
  mpz_t value;
  unsigned long result;

  mpz_init_set_ui(value, 21);
  mpz_mul_ui(value, value, 2);
  result = mpz_get_ui(value);
  mpz_clear(value);

  return result == 42 ? 0 : 1;
}
