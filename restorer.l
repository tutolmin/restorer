%{

#include <stdio.h>
#include <syslog.h>
#include "y.tab.h"

char s[80]="";
char k[80]="";

%}

%flex
%bison
%unicode

%%

^Queue {
	    syslog( LOG_DEBUG, "Read :Queue node: %s", yytext);
            return(QUEUE_NODE);
	}
^Engine {
	    syslog( LOG_DEBUG, "Read :Engine node: %s", yytext);
            return(ENGINE_NODE);
	}
^(Analysis) {
	    syslog( LOG_DEBUG, "Read :Analysis node: %s", yytext);
            return(ANALYSIS_NODE);
	}
(Head|Current|Tail) {
	    syslog( LOG_DEBUG, "Read :Queue label: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(QUEUE_LABEL);
	}
(BlackSide|WhiteSide|Pending|Complete) {
	    syslog( LOG_DEBUG, "Read :Analysis label: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(ANALYSIS_LABEL);
	}
(WebUser|Game|Line|Depth|Queue) {
	    syslog( LOG_DEBUG, "Read node: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(NODE);
	}
[[:xdigit:]]{8} {
	    syslog( LOG_DEBUG, "Read :Line hash: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(LINE_HASH);
	}
[[:xdigit:]]{32} {
	    syslog( LOG_DEBUG, "Read :Game hash: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(GAME_HASH);
	}
[[:xdigit:]]{8}-([[:xdigit:]]{4}-){3}[[:xdigit:]]{12} {
// bd4007d7-9df3-400a-a25c-01012ef46f29
	    syslog( LOG_DEBUG, "Read UUID: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(UUID);
	}
(REQUESTED_BY|REQUESTED_FOR|PERFORMED_ON|QUEUED|FIRST|LAST|REQUIRED_DEPTH) {
	    syslog( LOG_DEBUG, "Read analysis relationship: %s", yytext);
            strcpy(s, yytext); 
	    yylval.s = s;
            return(ANALYSIS_REL);
	}
[\n] { 
	    syslog( LOG_DEBUG, "Read new line");
            strcpy(k, yytext); 
	    yylval.k = k;
            return(NEWLINE);
	}
[ ] { 
//	    syslog( LOG_DEBUG, "Read space");
//          return(SPACE);
	}
.       { // Garbage
	    syslog( LOG_DEBUG, "???: %s", yytext);
	}
%%
