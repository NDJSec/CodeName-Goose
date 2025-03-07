#include <string.h>

char* strcpy(char* __restrict dst, const char* __restrict src) {
	const size_t length = strlen(src);
	//  The stpcpy() and strcpy() functions copy the string src to dst
	//  (including the terminating '\0' character).
	memcpy(dst, src, length + 1);
	//  The strcpy() and strncpy() functions return dst.
	return dst;
}