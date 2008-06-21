/* ZZJSON - Unicode Callbacks - Copyright (C) 2008 by Ivo van Poorten
 * License: GNU Lesser General Public License version 2.1
 */

#include <stdlib.h>
#include <stdarg.h>
#include <stdint.h>
#include "unicode_callbacks.h"

#ifdef CONFIG_NO_ERROR_MESSAGES
#define ERROR(x...)
#else
#define ERROR(x...)     uc->error(uc->ehandle, ##x)
#endif

static char hexval[] = "0123456789abcdef";

static inline uint16_t bswap16(uint16_t x) {
    return (x>>8) | (x<<8);
}

static inline uint32_t bswap32(uint32_t x) {
    x = ((x<<8)&0xff00ff00) | ((x>>8)&0x00ff00ff);
    return (x>>16) | (x<<16);
}

#define GETC()          uc->getchar(uc->ihandle)

static void parse_bom(UNIContext *uc) {
    int c;

    uc->bigendian = 0;
    c = GETC();

    if (c != 0xef && c!= 0xfe && c != 0xff && c != 0x00) { // no BOM
        uc->ungetchar(c, uc->ihandle);
        uc->type = UNI_UTF8;
        return;
    }

    c <<= 8;
    c |= GETC();

    switch (c) {
        case 0xefbb:
            c = GETC();
            if (c != 0xbf) break;
            uc->type = UNI_UTF8;
            return;
        case 0xfeff:
            uc->bigendian++;
            uc->type = UNI_UTF16;
            return;
        case 0xfffe:
            c = GETC();
            if (c) {
                uc->ungetchar(c, uc->ihandle);
                uc->type = UNI_UTF16;
                return;
            }
            c = GETC();
            if (!c) {
                uc->type = UNI_UTF32;
                return;
            }
            break;
        case 0x000:
            c  = GETC() << 8;
            c |= GETC();
            if (c != 0xfeff) break;
            uc->bigendian++;
            uc->type = UNI_UTF32;
            return;
        default:
            break;
    }

    ERROR("unicode: invalid BOM");
    uc->type = UNI_ERROR;
    return;
}

int unicode_getchar(UNIContext *uc) {
    int c;

    if (!uc->type)             parse_bom(uc);
    if (uc->type == UNI_ERROR) return -1;
    if (uc->bufp)              return uc->ungetcbuf[--uc->bufp];

doescape:
    if (uc->escape) {
        uc->escape--;
        switch (uc->escape) {
            case 11: case 5: return '\\';
            case 10: case 4: return 'u';
            default: {
                int s = uc->escape;
                if (s>3) s -= 2;
                return hexval[(uc->unival>>(s<<2))&15];
            }
        }
    }

    /* Accepts U+000000 ... U+10FFFF in all official Unicode encodings
     * (which are UTF-8, UTF-16 and UTF-32) and both byte orders.
     * All non-ASCII codes get converted to either one or two \uHHHH escapes.
     * It should accept CESU-8 automatically and emit two escape sequences
     * for a pair of surrogate triplets (not tested).
     */

    switch (uc->type) {
        case UNI_UTF8: {
            int b = 0;
            c = GETC();
                 if (c>=0xf8) {
illegal_utf8:
                     ERROR("unicode: illegal utf-8 sequence");
                     return -1;
                 }
            else if (c<=0x7f)   b=0;            // no continuation
            else if (c<=0xbf) { b=0; c&=0x3f; } // no continuation
            else if (c<=0xdf) { b=1; c&=0x1f; } // +1 byte
            else if (c<=0xef) { b=2; c&=0x0f; } // +2 bytes
            else if (c<=0xf7) { b=3; c&=0x07; } // +3 bytes

            while(b--) {
                int n = GETC();
                if ((n&0xc0) != 0x80) goto illegal_utf8;
                c <<= 6;
                c  |= n & 0x3f;
            }
            goto handle_as_utf32;
        }
        case UNI_UTF16:
            c = GETC();
            if (c<0) return -1;
            c |= GETC() << 8;
            if (uc->bigendian) c = bswap16(c);

handle_as_utf16:
            if (c <= 127) return c;     // no escape
            uc->unival = c;
            uc->escape = 6;
            goto doescape;
        case UNI_UTF32:
            c = GETC();
            if (c<0) return -1;
            c |= GETC() << 8;
            c |= GETC() << 16;
            c |= GETC() << 24;
            if (uc->bigendian) c = bswap32(c);
            if (c<0) return -1;

handle_as_utf32:
            if (c <  0x010000) goto handle_as_utf16;
            if (c >= 0x110000) {
                ERROR("unicode: codepoint >= 0x110000");
                return -1;
            }

            c -= 0x10000;
            uc->unival  = (0xd800 | (c>>10)) << 16;
            uc->unival |=  0xdc00 | (c&0x3ff);
            uc->escape  = 12;
            goto doescape;
        default:
            break;
    }
    return -1;
}

int unicode_ungetchar(int c, UNIContext *uc) {
    if (uc->bufp == UNGETCBUFSIZ)
        return -1;
    uc->ungetcbuf[uc->bufp++] = c;
    return c;
}

static const unsigned char boms[] = {
    0xef, 0xbb, 0xbf, 0xff, 0xfe, 0x00, 0x00, 0xfe, 0xff
};

static int print_bom(UNIContext *uc) {
    int len, i, r = 0;

    switch (uc->type) {
        case UNI_UTF8:  i = 0;                     len = 3; break;
        case UNI_UTF16: i = uc->bigendian ? 7 : 3; len = 2; break;
        case UNI_UTF32: i = uc->bigendian ? 5 : 3; len = 4; break;
        default: return -1;
    }
    for (; len; len--, i++)
        r |= uc->putchar(boms[i], uc->ohandle);
    uc->ostate = 1;
    return r;
}

/* used internally only; c is considered <= 16 bits
 * surrogates have to be converted for utf-8/utf-32
 */
static int output_unicode(unsigned int c, UNIContext *uc) {
    int r = 0;

    if (uc->type == UNI_UTF16) {
        if (uc->bigendian) c = bswap16(c);
        r |= uc->putchar( c    &0xff, uc->ohandle);
        r |= uc->putchar((c>>8)&0xff, uc->ohandle);
        return r;
    }

    if (uc->xunival) { /* saved high surrogate, current c is low surrogate */
        c &= 0x3ff;
        c |= (uc->xunival & 0x3ff) << 10;
        c += 0x10000;
        uc->xunival = 0;
    } else if ((c & 0xf800) == 0xd800) {
        uc->xunival = c;
        return r;
    }

    if (uc->type == UNI_UTF32) {
        if (uc->bigendian) c = bswap32(c);
        r |= uc->putchar( c     &0xff, uc->ohandle);
        r |= uc->putchar((c>> 8)&0xff, uc->ohandle);
        r |= uc->putchar((c>>16)&0xff, uc->ohandle);
        r |= uc->putchar((c>>24)&0xff, uc->ohandle);
        return r;
    }

           if (c<128) r |= uc->putchar(c, uc->ohandle);
      else if (c<2048) {
          r |= uc->putchar(0xc0 | ( c>>6 ),       uc->ohandle);
          r |= uc->putchar(0x80 | ( c     &0x3f), uc->ohandle);
    } else if (c<65536) {
          r |= uc->putchar(0xe0 | ( c>>12),       uc->ohandle);
          r |= uc->putchar(0x80 | ((c>>6 )&0x3f), uc->ohandle);
          r |= uc->putchar(0x80 |  (c     &0x3f), uc->ohandle);
    } else {
          r |= uc->putchar(0xf0 | ((c>>18)&0x07), uc->ohandle);
          r |= uc->putchar(0x80 | ((c>>12)&0x3f), uc->ohandle);
          r |= uc->putchar(0x80 | ((c>>6 )&0x3f), uc->ohandle);
          r |= uc->putchar(0x80 |  (c     &0x3f), uc->ohandle);
    }

    return r;
}

/* ostates: 0 - output BOM
 *          1 - normal
 *          2 - received '\', next should be 'u'
 *          3 - received 'u', next should be ... etc...
 *          4 - received H1
 *          5 - received H2
 *          6 - received H3
 */
int unicode_putchar(int c, UNIContext *uc) {
    UNIType type = uc->type;
    int r = 0;

    if (!uc->ostate) {
        if (type != UNI_UTF8 && type != UNI_UTF16 && type != UNI_UTF32) {
            ERROR("unicode: type not specified");
            return -1;
        }
        r |= print_bom(uc);
        if (r < 0) return -1;
    }

    switch (uc->ostate) {
        case 1:
            if (c != '\\') {
                r |= output_unicode(c, uc);
                break;
            }
            uc->ostate++;
            break;
        case 2:
            if (c != 'u') {
                r |= output_unicode('\\', uc);
                r |= output_unicode(c, uc);
                uc->ostate = 1;
                break;
            }
            uc->unival = 0;
            uc->ostate++;
            break;
        case 3:
        case 4:
        case 5:
        case 6:
            uc->unival <<= 4;
            uc->unival  |= (c&15) + (c>'9' ? 9 : 0);
            uc->ostate++;
            if (uc->ostate == 7) {
                r |= output_unicode(uc->unival, uc);
                uc->ostate = 1;
            }
            break;
        default:
            return -1;
    }
    return r;
}

#include <stdio.h>

int unicode_print(UNIContext *uc, const char *fmt, ...) {
    int len = 16, r;
    va_list ap;

    va_start(ap, fmt);
    while (1) {
        char tempbuf[len];
        int i;
        r = vsnprintf(tempbuf, len, fmt, ap);
        if (r < 0) goto errout;
        if (r >= len) {
            len *= 2;
            continue;
        }
        for (i=0; i<r; i++)
            unicode_putchar(tempbuf[i], uc);
errout:
        va_end(ap);
        return r;
    }
}
