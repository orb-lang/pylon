/* This file was automatically generated.  Do not edit! */

#include <termios.h>
#include <time.h>

#define FEMTO_VERSION "0.0.1-SNAPSHOT"
#define FEMTO_TAB_STOP 8
#define FEMTO_QUIT_TIMES 1

#define CTRL_KEY(k) ((k) & 0x1f)

enum fmKey {
  BACKSPACE = 127,
  ARROW_LEFT = 1000,
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


void initFm();
void fmProcessKeypress();
void fmMoveCursor(int key);
void fmDrawMessageBar(struct abuf *ab);
void fmDrawStatusBar(struct abuf *ab);
void fmDrawRows(struct abuf *ab);
void fmScroll();
void abFree(struct abuf *ab);
void abAppend(struct abuf *ab,const char *s,int len);
void fmFind();
void fmFindCallback(char *query,int key);
void fmSave();
void fmOpen(char *filename);
void *fmRowsToString(int *buflen);
void fmDelChar();
void fmInsertNewline();
void fmInsertChar(int c);
void fmRowDelChar(frow *row,int at);
void fmRowAppendString(frow *row,char *s,size_t len);
void fmRowInsertChar(frow *row,int at,int c);
void fmDelRow(int at);
void fmFreeRow(frow *row);
void fmInsertRow(int at,char *s,size_t len);
void fmUpdateRow(frow *row);
int fmRowRxToCx(frow *row,int rx);
int fmRowCxToRx(frow *row,int cx);
int fmSyntaxToColor(int hl);
void fmUpdateSyntax(frow *row);
int getWindowSize(int *rows,int *cols);
int getCursorPosition(int *rows,int *cols);
int fmReadKey();
void enableRawMode();
void disableRawMode();
void die(const char *s);
char *fmPrompt(char *prompt,void(*callback)(char *,int));
char *fmPrompt(char *prompt,void(*callback)(char *,int));
void fmRefreshScreen();
void fmRefreshScreen();
void fmSetStatusMessage(const char *fmt,...);
void fmSetStatusMessage(const char *fmt,...);
extern struct fmConfig F;
