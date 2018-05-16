void initFm(void);
void fmProcessKeypress(int c);
void fmMoveCursor(int key);
void fmDrawMessageBar(struct abuf *ab);
void fmDrawStatusBar(struct abuf *ab);
void fmDrawRows(struct abuf *ab);
void fmScroll(void);
void abFree(struct abuf *ab);
void abAppend(struct abuf *ab,const char *s,int len);
void fmFind(void);
void fmFindCallback(char *query,int key);
void fmSave(void);
void fmOpen(char *filename);
void *fmRowsToString(int *buflen);
void fmDelChar(void);
void fmInsertNewline(void);
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
int fmReadKey(void);
void raw(void);
void disableRawMode(void);
void enableRawMode(void);
void cooked(void);
void die(const char *s);
char *fmPrompt(char *prompt,void(*callback)(char *,int));
void fmRefreshScreen(void);
void fmSetStatusMessage(const char *fmt,...);
