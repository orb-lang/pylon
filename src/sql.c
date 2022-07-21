








































































































































































// Typedefs.
typedef struct sqlite3 sqlite3;
typedef struct sqlite3_stmt sqlite3_stmt;
typedef void (*sqlite3_destructor_type)(void*);
typedef struct sqlite3_context sqlite3_context;
typedef struct Mem sqlite3_value;

// Get informative error message.
const char *sqlite3_errmsg(sqlite3*);

// Connection.
int sqlite3_open_v2(const char *filename, sqlite3 **ppDb, int flags,
 const char *zVfs);
int sqlite3_close(sqlite3*);
int sqlite3_busy_timeout(sqlite3*, int ms);

// Statement.
int sqlite3_prepare_v2(sqlite3 *conn, const char *zSql, int nByte,
                       sqlite3_stmt **ppStmt, const char **pzTail);
int sqlite3_step(sqlite3_stmt*);
int sqlite3_reset(sqlite3_stmt *pStmt);
int sqlite3_finalize(sqlite3_stmt *pStmt);

// Extra functions for SELECT.
int sqlite3_column_count(sqlite3_stmt *pStmt);
const char *sqlite3_column_name(sqlite3_stmt*, int N);
int sqlite3_column_type(sqlite3_stmt*, int iCol);

// Get value from SELECT.
int64_t sqlite3_column_int64(sqlite3_stmt*, int iCol);
double sqlite3_column_double(sqlite3_stmt*, int iCol);
int sqlite3_column_bytes(sqlite3_stmt*, int iCol);
const unsigned char *sqlite3_column_text(sqlite3_stmt*, int iCol);
const void *sqlite3_column_blob(sqlite3_stmt*, int iCol);

// Set value in bind.
int sqlite3_bind_int64(sqlite3_stmt*, int, int64_t);
int sqlite3_bind_double(sqlite3_stmt*, int, double);
int sqlite3_bind_null(sqlite3_stmt*, int);
int sqlite3_bind_text(sqlite3_stmt*, int, const char*, int n, void(*)(void*));
int sqlite3_bind_blob(sqlite3_stmt*, int, const void*, int n, void(*)(void*));

int sqlite3_bind_parameter_index(sqlite3_stmt *stmt, const char *name);
const char *sqlite3_bind_parameter_name(sqlite3_stmt*, int);
int sqlite3_bind_parameter_count(sqlite3_stmt*);

// Clear bindings.
int sqlite3_clear_bindings(sqlite3_stmt*);

// Get value in callbacks.
int sqlite3_value_type(sqlite3_value*);
int64_t sqlite3_value_int64(sqlite3_value*);
double sqlite3_value_double(sqlite3_value*);
int sqlite3_value_bytes(sqlite3_value*);
const unsigned char *sqlite3_value_text(sqlite3_value*); //Not used.
const void *sqlite3_value_blob(sqlite3_value*);

// Set value in callbacks.
void sqlite3_result_error(sqlite3_context*, const char*, int);
void sqlite3_result_int64(sqlite3_context*, int64_t);
void sqlite3_result_double(sqlite3_context*, double);
void sqlite3_result_null(sqlite3_context*);
void sqlite3_result_text(sqlite3_context*, const char*, int, void(*)(void*));
void sqlite3_result_blob(sqlite3_context*, const void*, int, void(*)(void*));

// Persistency of data in callbacks (here just a pointer for tagging).
void *sqlite3_aggregate_context(sqlite3_context*, int nBytes);

// Typedefs for callbacks.
typedef void (*ljsqlite3_cbstep)(sqlite3_context*,int,sqlite3_value**);
typedef void (*ljsqlite3_cbfinal)(sqlite3_context*);

// Posix/libc sleep function, for non-blocking waits outside of event loops
unsigned int sleep(unsigned int seconds);

int usleep(int useconds); //pass in microseconds

// Register callbacks.
int sqlite3_create_function(
    sqlite3 *conn,
    const char *zFunctionName,
    int nArg,
    int eTextRep,
    void *pApp,
    void (*xFunc)(sqlite3_context*,int,sqlite3_value**),
    void (*xStep)(sqlite3_context*,int,sqlite3_value**),
    void (*xFinal)(sqlite3_context*)
);

