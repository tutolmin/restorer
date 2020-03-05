%{
#include <stdio.h>
#include <unistd.h>
#include <syslog.h>
#include <string.h>
#include <openssl/md5.h>

// Try to get more verbose output from byacc
#define YYERROR_VERBOSE 1

int yyerror( const char *s);
int yywrap( void);
//extern yy_buffer_state;
typedef struct yy_buffer_state * YY_BUFFER_STATE;

//typedef yy_buffer_state *YY_BUFFER_STATE;
int yyparse( void);
YY_BUFFER_STATE yy_scan_string(char *, size_t);
void yy_delete_buffer(YY_BUFFER_STATE buffer);

long queue_prev_id=-1;
char query[BUFSIZ]="";
char queue_labels_str[64]="";

char analysis_labels_str[64]="";

char tmp_str[BUFSIZ]="";
char json_str[BUFSIZ-4]="";
char moves_str[BUFSIZ]="";
char tags_str[BUFSIZ]="";
char roster_str[BUFSIZ]="";
char roster_hash[33]="";
char hashcode[9]="";

void flush_files( void);

%}

%start nodes

%token QUEUE_NODE ENGINE_NODE ANALYSIS_NODE QUEUE_LABEL ANALYSIS_LABEL NODE LINE_HASH GAME_HASH UUID ANALYSIS_REL NEWLINE

%union { char* s; char* k; }

%token <k> NEWLINE
%token <s> QUEUE_LABEL ANALYSIS_LABEL NODE LINE_HASH GAME_HASH UUID ANALYSIS_REL

%%                   /* beginning of rules section */

nodes:	engine_node
	|
	queue_node
	|
	analysis_node
	|
	nodes engine_node
	|
	nodes queue_node
	|
	nodes analysis_node
	;
engine_node:	ENGINE_NODE UUID NEWLINE
	{
	  sprintf( query, "CREATE (e:Engine) SET e.uuid=$uuid (uuid=%s)", $2);
	  syslog( LOG_NOTICE, "Query: %s", query);
	}
	;
queue_node:	queue_labels UUID NEWLINE
	{
	  sprintf( query, "MATCH (p:Queue) WHERE id(p)=$qid (qid=%ld) \
CREATE (q:%s) SET e.uuid=$uuid (uuid=%s) \
MERGE (p)-[:NEXT]->(q) \
RETURN id(q) as qid", queue_prev_id, queue_labels_str, $2);

	  // Very first :Queue:Head node needs special query
	  if( queue_prev_id == -1)
	    sprintf( query, "CREATE (q:%s) SET e.uuid=$uuid (uuid=%s) \
RETURN id(q) as qid", queue_labels_str, $2);

	  // Save new qid as queue_prev_id

	  syslog( LOG_NOTICE, "Query: %s", query);
	}
	;
queue_labels: QUEUE_NODE
	{
	  strcpy( queue_labels_str, "Queue");
	}
	|
	queue_labels QUEUE_LABEL
	{
	  strcat( queue_labels_str, ":");
	  strcat( queue_labels_str, $2);
	}
	;
analysis_node:	analysis_labels NEWLINE
	;
analysis_labels: ANALYSIS_NODE
	{
	  strcpy( analysis_labels_str, "Analysis");
	}
	|
	queue_labels ANALYSIS_LABEL
	{
	  strcat( analysis_labels_str, ":");
	  strcat( analysis_labels_str, $2);
	}
	;
analysis_rel:	ANALYSIS_REL
	|
	analysis_rel ANALYSIS_REL
	;
binding:	analysis_rel NODE GAME_HASH
	|
	analysis_rel NODE LINE_HASH
	|
	analysis_rel NODE UUID
	;
%%

int main( int argc, char **argv) {

	// Set log mask to avoid unnecessary output
	setlogmask( LOG_UPTO( LOG_DEBUG)); // LOG_NOTICE LOG_INFO LOG_DEBUG

	// Open syslog stream LOG_LOCAL1 
	openlog( "restorer", LOG_NDELAY, LOG_DAEMON);

        // Evaluator starting
        syslog( LOG_NOTICE, "Program start.");
	
        // Parse the line
        yyparse();

	return(0);
}

int yylex( void);

int yyerror( const char *s)
{
  syslog( LOG_ERR, "yyerror: %s", s);

  return(1);
}

int yywrap( void)
{
  syslog( LOG_NOTICE, "Program end.");

  return(1);
}
