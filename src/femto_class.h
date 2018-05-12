/* Not function-pointer structures for femto */


#include <termios.h>
#include <time.h>

#define FEMTO_VERSION "0.0.1-SNAPSHOT"
#define FEMTO_TAB_STOP 4
#define FEMTO_QUIT_TIMES 1

#define CTRL_KEY(k) ((k) & 0x1f)

enum fmKey {
  BACKSPACE = 127,
  ARROW_LEFT = 1 << 23,
  ARROW_RIGHT,
  ARROW_UP,
  ARROW_DOWN,
  DEL_KEY,
  HOME_KEY,
  END_KEY,
  PAGE_UP,
  PAGE_DOWN
};

enum fmHighlight {
  HL_NORMAL = 0,
  HL_NUMBER,
  HL_MATCH
};

/*** data ***/

typedef struct frow {
  int size;
  int rsize;
  char *chars;
  char *render;
  unsigned char *hl;
} frow;

struct fmConfig {
  int cx, cy;
  int rx;
  int rowoff;
  int coloff;
  int screenrows;
  int screencols;
  int numrows;
  frow *row;
  int dirty;
  char *filename;
  char statusmsg[80];
  time_t statusmsg_time;
  struct termios orig_termios;
};

struct fmConfig F;

struct abuf {
  char *b;
  int len;
};

extern struct fmConfig F;
