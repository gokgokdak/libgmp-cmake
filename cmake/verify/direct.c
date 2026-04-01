#include <gmp.h>

int
main(void)
{
  mpz_t value;
  unsigned long result;

  mpz_init_set_ui(value, 6);
  mpz_mul_ui(value, value, 7);
  result = mpz_get_ui(value);
  mpz_clear(value);

  return result == 42 ? 0 : 1;
}
