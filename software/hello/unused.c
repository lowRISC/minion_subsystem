
void *memcpy(void *__restrict__ dst, const void * __restrict__ src, size_t N) {
  char * __restrict__ dst_ = (char * __restrict__ )dst;
  const char * __restrict__ src_ = (char * __restrict__ )src;
  for (size_t i = 0; i != N; ++i)
    dst_[i] = src_[i];
  return dst;
}

int memcmp(const void *x, const void *y, size_t N) {
  if (x == y)
    return 0;

  const char *x_ = (const char *)x;
  const char *y_ = (const char *)y;
  for (size_t i = 0; i != N; ++i) {
    int delta = x_[i] - y_[i];
    if (delta)
      return delta;
  }
  return 0;
}

void *memset(void *dst, int V, size_t N) {
  char *dst_ = (char *) dst;
  for (size_t i = 0; i != N; ++i)
    dst_[i] = V;
  return dst;
}

char *strncpy(char *dest, const char *src, size_t n)
{
  size_t i;
  
  for (i = 0; i < n && src[i] != '\0'; i++)
    dest[i] = src[i];
  for ( ; i < n; i++)
    dest[i] = '\0';
  
  return dest;
}

int strcmp (const char *s1, const char *s2)
 {
  /* No checks for NULL */
  char *s1p = (char *)s1;
  char *s2p = (char *)s2;

  while (*s2p != '\0')
    {
      if (*s1p != *s2p)
        break;

      ++s1p;
      ++s2p;
    }
  return (*s1p - *s2p);
}

char* strcpy (char *s1, const char *s2)
{
  char *s1p = (char *)s1;
  char *s2p = (char *)s2;

  while (*s2p != '\0')
  {
    (*s1p) = (*s2p);

    ++s1p;
    ++s2p;
  }

  return s1;
}

size_t strlen (const char *str)
{
  char *s = (char *)str;
  size_t len = 0;

  if (s == NULL)
    return 0;

  while (*s++ != '\0')
    ++len;
  return len;
}
