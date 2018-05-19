
/*** includes ***/

#define _DEFAULT_SOURCE
#define _BSD_SOURCE
#define _GNU_SOURCE

#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <unistd.h>


#include "femto_class.h"

/*** prototypes ***/

void fmSetStatusMessage(const char *fmt, ...);
void fmRefreshScreen();
char *fmPrompt(char * prompt, void (*callback)(char *, int));

/*** terminal ***/

void die(const char *s) {
  write(STDOUT_FILENO, "\x1b[2J", 4);
  write(STDOUT_FILENO, "\x1b[H", 3);

  perror(s);
  exit(1);
}

void cooked() {
  if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &F.orig_termios) == -1)
    die("tcsetattr");
}

// todo remove almost everything in this file
void enableRawMode() {}
void disableRawMode() {}

void raw() {
  if (tcgetattr(STDIN_FILENO, &F.orig_termios) == -1) die("tcgetattr");
  atexit(disableRawMode);

  struct termios raw = F.orig_termios;
  raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
  raw.c_oflag &= ~(OPOST);
  raw.c_cflag |= (CS8);
  raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
  raw.c_cc[VMIN] = 0;
  raw.c_cc[VTIME] = 1;

  if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) == -1) die("tcsetattr");
}

int fmReadKey() {
  int nread;
  char c;
  while ((nread = read(STDIN_FILENO, &c, 1)) != 1) {
    if (nread == -1 && errno != EAGAIN) die("read");
  }

  if (c == '\x1b') {
    char seq[3];

    if (read(STDIN_FILENO, &seq[0], 1) != 1) return '\x1b';
    if (read(STDIN_FILENO, &seq[1], 1) != 1) return '\x1b';

    if (seq[0] == '[') {
      if (seq[1] >= '0' && seq[1] <= '9') {
        if (read(STDIN_FILENO, &seq[2], 1) != 1) return '\x1b';
        if (seq[2] == '~') {
          switch (seq[1]) {
            case '1': return HOME_KEY;
            case '3': return DEL_KEY;
            case '4': return END_KEY;
            case '5': return PAGE_UP;
            case '6': return PAGE_DOWN;
            case '7': return HOME_KEY;
            case '8': return END_KEY;
          }
        }
      } else {
      switch (seq[1]) {
        case 'A': return ARROW_UP;
        case 'B': return ARROW_DOWN;
        case 'C': return ARROW_RIGHT;
        case 'D': return ARROW_LEFT;
        case 'H': return HOME_KEY;
        case 'F': return END_KEY;
        }
      }
    } else if (seq[0] == '0') {
      switch (seq[1]) {
        case 'H': return HOME_KEY;
        case 'F': return END_KEY;
      }
    }

    return '\x1b';
  } else {
    return c;
  }
}


int getCursorPosition(int *rows, int *cols) {
  char buf[32];
  unsigned int i = 0;

  if (write(STDOUT_FILENO, "\x1b[6n", 4) != 4) return -1;

  while (i < sizeof(buf) - 1) {
    if (read(STDIN_FILENO, &buf[i], 1) != 1) break;
    if (buf[i] == 'R') break;
    i++;
  }
  buf[i] = '\0';

  if (buf[0] != '\x1b' || buf[1] != '[') return -1;
  if (sscanf(&buf[2], "%d;%d", rows, cols) != 2) return -1;

  return 0;
}

int getWindowSize(int *rows, int *cols) {
  struct winsize ws;

  if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == -1 || ws.ws_col == 0) {
    if (write(STDOUT_FILENO, "\x1b[999C\x1b[999B", 12) != 12) return -1;
    return getCursorPosition(rows, cols);
    return -1;
  } else {
    *cols = ws.ws_col;
    *rows = ws.ws_row;
    return 0;
  }
}

/*** syntax highlighting ***/

void fmUpdateSyntax(frow *row) {
  row->hl = realloc(row->hl, row->rsize);
  memset(row->hl, HL_NORMAL, row->rsize);

  int i;
  for (i = 0; i < row->rsize; i++) {
    if (isdigit(row->render[i])) {
      row->hl[i] = HL_NUMBER;
    }
  }
}

int fmSyntaxToColor(int hl) {
  switch (hl) {
    case HL_NUMBER: return 31;
    case HL_MATCH: return 34;
    default: return 37;
  }
}

/*** row operations ***/

int fmRowCxToRx(frow *row, int cx) {
  int rx = 0;
  int j;
  for (j = 0; j < cx; j++) {
    if (row->chars[j] == '\t')
      rx += (FEMTO_TAB_STOP - 1) - (rx % FEMTO_TAB_STOP);
    rx++;
  }
  return rx;
}

int fmRowRxToCx(frow *row, int rx) {
  int cur_rx = 0;
  int cx;
  for (cx = 0; cx < row->size; cx++) {
    if (row->chars[cx] == '\t')
      cur_rx += (FEMTO_TAB_STOP - 1) - (cur_rx % FEMTO_TAB_STOP);
    cur_rx++;

    if (cur_rx > rx) return cx;
  }
  return cx;
}

void fmUpdateRow(frow *row) {
  int tabs = 0;
  int j;
  for(j = 0; j < row->size; j++)
    if (row->chars[j] == '\t') tabs++;

  free(row->render);
  row->render = malloc(row->size + tabs*(FEMTO_TAB_STOP - 1)  + 1);

  int idx = 0;

  for (j = 0; j < row->size; j++) {
    if (row->chars[j] == '\t') {
      row->render[idx++] = ' ';
      while (idx % FEMTO_TAB_STOP != 0) row->render[idx++] = ' ';
    } else {
      row->render[idx++] = row->chars[j];
    }
  }
  row->render[idx] = '\0';
  row->rsize = idx;

  fmUpdateSyntax(row);
}



void fmInsertRow(int at, char *s, size_t len) {
  if (at < 0 || at > F.numrows) return;

  F.row = realloc(F.row, sizeof(frow) * (F.numrows + 1));
  memmove(&F.row[at + 1], &F.row[at], sizeof(frow) * (F.numrows - at));

  F.row[at].size = len;
  F.row[at].chars = malloc(len + 1);
  memcpy(F.row[at].chars, s, len);
  F.row[at].chars[len] = '\0';

  F.row[at].rsize = 0;
  F.row[at].render = NULL;
  F.row[at].hl = NULL;
  fmUpdateRow(&F.row[at]);

  F.numrows++;
  F.dirty++;
}

void fmFreeRow(frow *row) {
  free(row->render);
  free(row->chars);
  free(row->hl);
}

void fmDelRow(int at) {
  if (at < 0 || at >= F.numrows) return;
  fmFreeRow(&F.row[at]);
  memmove(&F.row[at], &F.row[at + 1], sizeof(frow) * (F.numrows - at - 1));
  F.numrows--;
  F.dirty++;
}

void fmRowInsertChar(frow *row, int at, int c) {
  if (at < 0 || at > row->size) at = row->size;
  row->chars = realloc(row->chars, row->size + 2);
  memmove(&row->chars[at + 1], &row->chars[at], row->size - at + 1);
  row->size++;
  row->chars[at] = c;
  fmUpdateRow(row);
  F.dirty++;
}

void fmRowAppendString(frow *row, char *s, size_t len) {
  row->chars = realloc(row->chars, row->size + len + 1);
  memcpy(&row->chars[row->size], s, len);
  row->size += len;
  row->chars[row->size] = '\0';
  fmUpdateRow(row);
  F.dirty++;
}

void fmRowDelChar(frow *row, int at) {
  if (at < 0 || at >= row->size) return;
  memmove(&row->chars[at], &row->chars[at + 1], row->size - at);
  row->size--;
  fmUpdateRow(row);
  F.dirty++;
}

/*** editor operations ***/

void fmInsertChar(int c) {
  if (F.cy == F.numrows) {
    fmInsertRow(F.numrows, "", 0);
  }
  fmRowInsertChar(&F.row[F.cy], F.cx, c);
  F.cx++;
}

void fmInsertNewline() {
  if (F.cx == 0) {
    fmInsertRow(F.cy, ".", 0);
  } else {
    frow *row = &F.row[F.cy];
    fmInsertRow(F.cy + 1, &row->chars[F.cx], row->size - F.cx);
    row = &F.row[F.cy];
    row->size = F.cx;
    row->chars[row->size] = '\0';
    fmUpdateRow(row);
  }
  F.cy++;
  F.cx = 0;
}

void fmDelChar() {
  if (F.cy == F.numrows) return;
  if (F.cx == 0 && F.cy == 0) return;

  frow *row = &F.row[F.cy];
  if (F.cx > 0) {
    fmRowDelChar(row, F.cx - 1);
    F.cx--;
  } else {
    F.cx = F.row[F.cy -1].size;
    fmRowAppendString(&F.row[F.cy - 1], row->chars, row->size);
    fmDelRow(F.cy);
    F.cy--;
  }
}

/*** file i/o ***/

void *fmRowsToString(int *buflen) {
  int totlen = 0;
  int j;
  for (j = 0; j < F.numrows; j++)
    totlen += F.row[j].size + 1;
  *buflen = totlen;

  char *buf = malloc(totlen);
  char *p = buf;
  for(j = 0; j < F.numrows; j++) {
    memcpy(p, F.row[j].chars, F.row[j].size);
    p += F.row[j].size;
    *p = '\n';
    p++;
  }

  return buf;
}

void fmOpen(char *filename) {
  free(F.filename);
  F.filename = strdup(filename);

  FILE *fp = fopen(filename, "r");
  if (!fp) die("fopen");

  char *line = NULL;
  size_t linecap = 0;
  ssize_t linelen;
  while ((linelen = getline(&line, &linecap, fp)) != -1) {
    while (linelen > 0 && (line[linelen - 1] == '\n' ||
                           line[linelen - 1] == '\r'))
      linelen--;
    fmInsertRow(F.numrows, line, linelen);
  }
  free(line);
  fclose(fp);
  F.dirty = 0;
}

void fmSave() {
  if (F.filename == NULL) {
    F.filename = fmPrompt("Save as: %s (ESC to cancel)", NULL);
    if (F.filename == NULL) {
      fmSetStatusMessage("Save cancelled");
      return;
    }
  }

  int len;
  char *buf = fmRowsToString(&len);

  int fd = open(F.filename, O_RDWR | O_CREAT, 0644);
  if (fd != -1) {
    if (ftruncate(fd, len) != -1) {
      if (write(fd, buf, len) == len) {
        close(fd);
        free(buf);
        F.dirty = 0;
        fmSetStatusMessage("%d bytes written to disk", len);
        return;
      }
    }
    close(fd);
  }

  free(buf);
  fmSetStatusMessage("Can't save! I/O error: %s", strerror(errno));
}
/*** find ***/

void fmFindCallback(char *query, int key) {
  static int last_match = -1;
  static int direction = 1;

  static int saved_hl_line;
  static char *saved_hl = NULL;

  if (saved_hl) {
    memcpy(F.row[saved_hl_line].hl, saved_hl, F.row[saved_hl_line].rsize);
    free(saved_hl);
    saved_hl = NULL;
  }

  if (key == '\r' || key == '\x1b') {
    last_match = -1;
    direction = 1;
    return;
  } else if (key == ARROW_RIGHT || key == ARROW_DOWN) {
    direction = 1;
  } else if (key == ARROW_LEFT || key == ARROW_UP) {
    direction = -1;
  } else {
    last_match = -1;
    direction = 1;
  }

  if (last_match == -1) direction = 1;
  int current = last_match;
  int i;
  for (i = 0; i < F.numrows; i++) {
    current += direction;
    if (current == -1) current = F.numrows - 1;
    else if (current == F.numrows) current = 0;

    frow *row = &F.row[current];
    char *match = strstr(row->render, query);
    if (match) {
      last_match = current;
      F.cy = current;
      F.cx = fmRowRxToCx(row, match - row->render);
      F.rowoff = F.numrows;

      saved_hl_line = current;
      saved_hl = malloc(row->rsize);
      memcpy(saved_hl, row->hl, row->rsize);
      memset(&row->hl[match - row->render], HL_MATCH, strlen(query));
      break;
    }
  }
}

void fmFind() {
  int saved_cx = F.cx;
  int saved_cy = F.cy;
  int saved_coloff = F.coloff;
  int saved_rowoff = F.rowoff;

  char *query = fmPrompt("Search: %s (Use ESC/Arrows/Enter)", fmFindCallback);

  if (query) {
    free(query);
  } else {
    F.cx = saved_cx;
    F.cy = saved_cy;
    F.coloff = saved_coloff;
    F.rowoff = saved_rowoff;
  }
}

/*** append buffer ***/

#define ABUF_INIT {NULL, 0}

void abAppend(struct abuf *ab, const char *s, int len) {
  char *new = realloc(ab->b, ab->len + len);

  if (new == NULL) return;
  memcpy(&new[ab->len], s, len);
  ab->b = new;
  ab->len += len;
}

void abFree(struct abuf *ab) {
  free(ab->b);
}




/*** output ***/

void fmScroll() {
  F.rx = 0;
  if (F.cy < F.numrows) {
    F.rx = fmRowCxToRx(&F.row[F.cy], F.cx);
  }

  if (F.cy < F.rowoff) {
    F.rowoff = F.cy;
  }
  if (F.cy >= F.rowoff + F.screenrows) {
    F.rowoff = F.cy - F.screenrows + 1;
  }
  if (F.rx < F.coloff) {
    F.coloff = F.rx;
  }
  if (F.rx >= F.coloff + F.screencols) {
    F.coloff = F.rx - F.screencols + 1;
  }
}

void fmDrawRows(struct abuf *ab) {
  int y;
  for (y = 0; y < F.screenrows; y++) {
    int filerow = y + F.rowoff;
    if (filerow >= F.numrows) {
      if (F.numrows == 0 && y == F.screenrows / 3) {
        char welcome[80];
        int welcomelen = snprintf(welcome, sizeof(welcome),
          "Femto Termenv -- version %s", FEMTO_VERSION);
        if (welcomelen > F.screencols) welcomelen = F.screencols;
        int padding = (F.screencols - welcomelen) / 2;
        if (padding) {
          abAppend(ab, "~", 1);
          padding--;
        }
        while (padding--) abAppend(ab, " ", 1);
        abAppend(ab, welcome, welcomelen);
      } else {
        abAppend(ab, "~", 1);
      }
    } else {
      int len = F.row[filerow].rsize - F.coloff;
      if (len < 0) len = 0;
      if (len > F.screencols) len = F.screencols;
      char *c = &F.row[filerow].render[F.coloff];
      unsigned char *hl = &F.row[filerow].hl[F.coloff];
      int current_color = -1;
      int j;
      for (j = 0; j < len; j++) {
        if (hl[j] == HL_NORMAL) {
          if (current_color != -1) {
            abAppend(ab, "\x1b[39m", 5);
            current_color = -1;
          }
          abAppend(ab, &c[j], 1);
        } else {
          int color = fmSyntaxToColor(hl[j]);
          if (color != current_color) {
            current_color = color;
            char buf[16];
            int clen = snprintf(buf, sizeof(buf), "\x1b[%dm", color);
            abAppend(ab, buf, clen);
          }
          abAppend(ab, &c[j], 1);
        }
      }
      abAppend(ab, "\x1b[39m", 5);
    }

    abAppend(ab, "\x1b[K",3);
    abAppend(ab, "\r\n", 2);
  }
}

void fmDrawStatusBar(struct abuf *ab) {
  abAppend(ab, "\x1b[7m", 4);
  char status[80], rstatus[80];
  int len = snprintf(status, sizeof(status), "%.20s - %d lines %s",
    F.filename ? F.filename : "[No Name]", F.numrows,
    F.dirty ? "(modified)" : "");
  int rlen = snprintf(rstatus, sizeof(rstatus), "%d/%d",
    F.cy + 1, F.numrows);
  if (len > F.screencols) len = F.screencols;
  abAppend(ab, status, len);
  while (len < F.screencols) {
    if (F.screencols - len == rlen) {
      abAppend(ab, rstatus, rlen);
      break;
    } else {
      abAppend(ab, " ", 1);
      len++;
    }
  }
  abAppend(ab, "\x1b[m", 3);
  abAppend(ab, "\r\n", 2);
}

void fmDrawMessageBar(struct abuf *ab) {
  abAppend(ab, "\x1b[K", 3);
  int msglen = strlen(F.statusmsg);
  if (msglen > F.screencols) msglen = F.screencols;
  if (msglen && time(NULL) - F.statusmsg_time < 5)
    abAppend(ab, F.statusmsg, msglen);
}

void fmRefreshScreen() {
  fmScroll();

  struct abuf ab = ABUF_INIT;

  abAppend(&ab, "\x1b[?25l", 6);
  abAppend(&ab, "\x1b[H", 3);

  fmDrawRows(&ab);
  fmDrawStatusBar(&ab);
  fmDrawMessageBar(&ab);

  char buf[32];
  snprintf(buf, sizeof(buf), "\x1b[%d;%dH", (F.cy - F.rowoff) + 1,
                                            (F.rx - F.coloff) + 1);
  abAppend(&ab, buf, strlen(buf));

  abAppend(&ab, "\x1b[?25h", 6);

  write(STDOUT_FILENO, ab.b, ab.len);
  abFree(&ab);
}

void fmSetStatusMessage(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  vsnprintf(F.statusmsg, sizeof(F.statusmsg), fmt, ap);
  va_end(ap);
  F.statusmsg_time = time(NULL);
}

/*** input ***/

char *fmPrompt(char *prompt, void (* callback)(char *, int)) {
  size_t bufsize = 128;
  char *buf = malloc(bufsize);

  size_t buflen = 0;
  buf[0] = '\0';

  while (1) {
    fmSetStatusMessage(prompt, buf);
    fmRefreshScreen();

    int c = fmReadKey();
    if (c == DEL_KEY || c == CTRL_KEY('h') || c == BACKSPACE) {
      if (buflen != 0) buf[--buflen] = '\0';
    } else if (c == '\x1b') {
      fmSetStatusMessage("");
      if (callback) callback(buf, c);
      free(buf);
      return NULL;
    } else if (c == '\r') {
      if (buflen != 0) {
        fmSetStatusMessage("");
        if (callback) callback(buf, c);
        return buf;
      }
    } else if (!iscntrl(c) && c < 128) {
      if (buflen == bufsize -1) {
        bufsize *=2;
        buf = realloc(buf, bufsize);
      }
      buf[buflen++] = c;
      buf[buflen] = '\0';
    }

    if (callback) callback(buf, c);
  }
}


void fmMoveCursor(int key) {
  frow *row = (F.cy >= F.numrows) ? NULL : &F.row[F.cy];

  switch(key) {
    case ARROW_LEFT:
      if (F.cx != 0) {
        F.cx--;
      } else if (F.cy > 0) {
        F.cy--;
        F.cx = F.row[F.cy].size;
      }
      break;
    case ARROW_RIGHT:
      if (row && F.cx < row->size) {
        F.cx++;
      } else if (row && F.cx == row->size) {
        F.cy++;
        F.cx = 0;
      }
      break;
    case ARROW_UP:
      if (F.cy != 0) {
        F.cy--;
      }
      break;
    case ARROW_DOWN:
      if (F.cy < F.numrows) {
        F.cy++;
      }
      break;
  }

  row = (F.cy >= F.numrows) ? NULL : &F.row[F.cy];
  int rowlen = row ? row->size : 0;
  if (F.cx > rowlen) {
    F.cx = rowlen;
  }
}

void fmProcessKeypress(int c) {
  static int quit_times = FEMTO_QUIT_TIMES;
  switch (c) {
    case '\r':
      fmInsertNewline();
      break;

    case CTRL_KEY('q'):
      if (F.dirty && quit_times >0) {
        fmSetStatusMessage("WARNING!!! File has unsaved changes. "
          "Press Ctrl-Q again to quit.");
        quit_times--;
        return;
      }
      write(STDOUT_FILENO, "\x1b[2j", 4);
      write(STDOUT_FILENO, "\x1b[h", 3);
      exit(0);
      break;

    case CTRL_KEY('s'):
      fmSave();
      break;

    case HOME_KEY:
      F.cx = 0;
      break;

    case END_KEY:
      if (F.cy < F.numrows)
        F.cx = F.row[F.cy].size;
      break;

    case CTRL_KEY('f'):
      fmFind();
      break;

    case BACKSPACE:
    case CTRL_KEY('h'):
    case DEL_KEY:
      if (c == DEL_KEY) fmMoveCursor(ARROW_RIGHT);
      fmDelChar();
      break;

    case PAGE_UP:
    case PAGE_DOWN:
      {
        if (c == PAGE_UP) {
          F.cy = F.rowoff;
        } else if (c == PAGE_DOWN) {
          F.cy = F.rowoff + F.screenrows - 1;
          if (F.cy > F.numrows) F.cy = F.numrows;
        }

        int times = F.screenrows;
        while (times--)
          fmMoveCursor(c == PAGE_UP ? ARROW_UP : ARROW_DOWN);
      }
      break;

    case ARROW_UP:
    case ARROW_DOWN:
    case ARROW_LEFT:
    case ARROW_RIGHT:
      fmMoveCursor(c);
      break;

    case CTRL_KEY('l'):
    case '\x1b':
      break;

    default:
      fmInsertChar(c);
      break;
  }
  quit_times = FEMTO_QUIT_TIMES;
}

/*** init ***/

void initFm() {
  F.cx = 0;
  F.cy = 0;
  F.rx = 0;
  F.rowoff = 0;
  F.coloff = 0;
  F.numrows = 0;
  F.row = NULL;
  F.dirty = 0;
  F.filename = NULL;
  F.statusmsg[0] = '\0';
  F.statusmsg_time = 0;

  if (getWindowSize(&F.screenrows, &F.screencols) == -1) die("getwindowsize");
  F.screenrows -= 2;
}

