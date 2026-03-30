      ****************************************************************
      *            IDENTIFICATION DIVISION                         ***
      ****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. WORDGAME.
      ****************************************************************
      *            ENVIRONMENT DIVISION                           ***
      ****************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      ****************************************************************
      **           DATA DIVISION                                   ***
      ****************************************************************
       DATA DIVISION.
       FILE SECTION.
       WORKING-STORAGE SECTION.
      * WS-VARIABLES
       01 WS-MAXWORDID        PIC S9(9) USAGE COMP.
       01 WS-WORDID           PIC S9(9) USAGE COMP.
       01 WS-RANDOMNR         PIC S9V9(6) COMP-3.
       01 WS-RANDOMID         PIC S9(9) USAGE COMP.
       01 WS-WORD             PIC X(10).
       01 WS-I                PIC 9(02) COMP VALUE 1.
       01 WS-CHAR-COUNT       PIC 9(02) VALUE 0.
       01 WS-POS              PIC 9(02) VALUE 1.
       01 WS-GUESS            PIC X(10).

       01 WS-WORD-TEMP        PIC 9(02).
       01 WS-MAXCHAR          PIC 9(02) VALUE 10.
       01 WS-WORD-LENGTH      PIC 9(02) VALUE 0.

       01 SWITCHES            PIC 9.
          88 1STSCR-SWITCH              VALUE 1.
          88 2NDSCR-SWITCH              VALUE 2.
          88 3RDSCR-SWITCH              VALUE 3.

       01 WS-COUNTER1         PIC 9(02).
       01 WS-COUNTER2         PIC 9(02).

       01 WS-COMMAREA         PIC 9(02).

       COPY DFHAID.
       COPY DFHBMSCA.
       COPY WORDS.
       COPY WORDSDB2.
      * DB2 AREA
           EXEC SQL
             INCLUDE SQLCA
           END-EXEC.

      *LINKAGE SECTION.
      *01 DFHCOMMAREA    PIC X(02).
       LINKAGE SECTION.
       01 DFHCOMMAREA    PIC 9(02).

      ****************************************************************
      **           PROCEDURE DIVISION                              ***
      ****************************************************************
       PROCEDURE DIVISION.
      ****************************************************************
      *A MAIN SECTION
      ****************************************************************
       A-MAIN SECTION.
           PERFORM B-CICS-SECTION
           GOBACK
           .
      ****************************************************************
      *B CICS SECTION                                                *
      *LOGIC FOR DIFFERENT KEY PRESSES IN CICS                       *
      ****************************************************************
       B-CICS-SECTION.

           EVALUATE TRUE
           WHEN EIBCALEN = ZERO
      *       LOGIC FOR THE FIRST CALL OF THE PROGRAM
             MOVE LOW-VALUES TO HOMESCRO
             MOVE 0 TO WS-COMMAREA
             PERFORM QA-MAXWORD
             PERFORM C-SEND-MAP2
             SET 1STSCR-SWITCH TO TRUE

           WHEN EIBAID = DFHCLEAR
      *       LOGIC FOR WHEN THE USER PRESSES THE CLEAR KEY
             MOVE LOW-VALUES TO GAMESCRO
             PERFORM C-SEND-MAP

           WHEN EIBAID = DFHENTER AND 2NDSCR-SWITCH
      *       USER PRESSES ENTER KEY
             MOVE LOW-VALUES TO GAMESCRO
             INITIALIZE MSG1O
             PERFORM D-RECEIVE-MAP
             PERFORM FA-CHECK-INPUT
             PERFORM FB-DRAW-HANGMAN
             PERFORM FC-CHECK-WINLOSS
             PERFORM E-SEND-DATA

           WHEN EIBAID = DFHPF2
      *       F2 NEW GAME
             MOVE LOW-VALUES TO GAMESCRO
             MOVE 0 TO WS-COUNTER1
             MOVE 0 TO WS-COUNTER2
             MOVE SPACES TO WS-GUESS
             PERFORM QA-MAXWORD
             PERFORM QB-RANDOMIZE
             PERFORM QC-SELECT
             PERFORM QD-MAPATTR
             PERFORM C-SEND-MAP
             SET 2NDSCR-SWITCH TO TRUE

           WHEN EIBAID = DFHPF3
      *       F3 EXIT GAME
             MOVE LOW-VALUES TO GAMESCRO
             MOVE 'END OF GAME. PRESS CLEAR'
               TO MSG2O
             PERFORM E-SEND-DATA
             EXEC CICS
               RETURN
             END-EXEC

           WHEN OTHER
             IF 2NDSCR-SWITCH
      *       LOGIC FOR ANY OTHER CASES
                MOVE LOW-VALUES TO GAMESCRO
                MOVE 'INVALID KEY PRESSED' TO MSG1O
                PERFORM E-SEND-DATA
             END-IF
           END-EVALUATE

           EXEC CICS
             RETURN TRANSID('WRDS')
             COMMAREA (WS-COMMAREA)
             LENGTH(02)
           END-EXEC
           .
      ****************************************************************
      *C SEND MAP SECTION                                            *
      ****************************************************************
       C-SEND-MAP SECTION.
           EXEC CICS SEND
             MAP     ('GAMESCR')
             MAPSET  ('WORDS')
             FROM    (GAMESCRO)
             ERASE
           END-EXEC
           .
      ****************************************************************
      *C SEND MAP SECTION                                            *
      ****************************************************************
       C-SEND-MAP2 SECTION.
           EXEC CICS SEND
             MAP     ('HOMESCR')
             MAPSET  ('WORDS')
             FROM    (HOMESCRO)
             ERASE
           END-EXEC
           .
      ****************************************************************
      *D RECEIVE MAP SECTION                                         *
      ****************************************************************
       D-RECEIVE-MAP SECTION.
           EXEC CICS RECEIVE
             MAP     ('GAMESCR')
             MAPSET  ('WORDS')
             INTO    (GAMESCRI)
           END-EXEC
           .
      ****************************************************************
      *E SEND DATA SECTION                                           *
      ****************************************************************
       E-SEND-DATA SECTION.
           EXEC CICS SEND
             MAP     ('GAMESCR')
             MAPSET  ('WORDS')
             FROM    (GAMESCRO)
             DATAONLY
           END-EXEC
           .
      ****************************************************************
      *F CHECK INPUT SECTION                                         *
      ****************************************************************
       FA-CHECK-INPUT SECTION.
            INITIALIZE MSG1O
            MOVE 0 TO WS-CHAR-COUNT
            INSPECT WORD TALLYING WS-CHAR-COUNT FOR ALL INPUTI

            IF WS-CHAR-COUNT = 0 AND INPUTI IS ALPHABETIC
               MOVE 'WRONG CHARACTER!' TO MSG1O
               ADD 1 TO WS-COUNTER1
      *        MOVE WS-COUNTER1 TO MSG4O
                EVALUATE TRUE
                 WHEN WS-COUNTER1 = 1
                      MOVE INPUTI TO CHARW1O
                 WHEN WS-COUNTER1 = 2
                      MOVE INPUTI TO CHARW2O
                 WHEN WS-COUNTER1 = 3
                      MOVE INPUTI TO CHARW3O
                 WHEN WS-COUNTER1 = 4
                      MOVE INPUTI TO CHARW4O
                 WHEN WS-COUNTER1 = 5
                      MOVE INPUTI TO CHARW5O
                 WHEN WS-COUNTER1 = 6
                      MOVE INPUTI TO CHARW6O
                 WHEN WS-COUNTER1 = 7
                      MOVE INPUTI TO CHARW7O
                 WHEN WS-COUNTER1 = 8
                      MOVE INPUTI TO CHARW8O
                 WHEN WS-COUNTER1 = 9
                      MOVE INPUTI TO CHARW9O
                 WHEN WS-COUNTER1 = 10
                      MOVE INPUTI TO CHARW10O
                END-EVALUATE
            ELSE
                ADD 1 TO WS-COUNTER2
      *         MOVE WS-COUNTER2 TO MSG2O
                PERFORM VARYING WS-POS FROM 1 BY 1 UNTIL WS-POS > 10
                   IF INPUTI = WORD(WS-POS:1)
                       EVALUATE WS-POS
                           WHEN 1  MOVE INPUTI TO CHAR1O WS-GUESS(1:1)
                           WHEN 2  MOVE INPUTI TO CHAR2O WS-GUESS(2:1)
                           WHEN 3  MOVE INPUTI TO CHAR3O WS-GUESS(3:1)
                           WHEN 4  MOVE INPUTI TO CHAR4O WS-GUESS(4:1)
                           WHEN 5  MOVE INPUTI TO CHAR5O WS-GUESS(5:1)
                           WHEN 6  MOVE INPUTI TO CHAR6O WS-GUESS(6:1)
                           WHEN 7  MOVE INPUTI TO CHAR7O WS-GUESS(7:1)
                           WHEN 8  MOVE INPUTI TO CHAR8O WS-GUESS(8:1)
                           WHEN 9  MOVE INPUTI TO CHAR9O WS-GUESS(9:1)
                           WHEN 10 MOVE INPUTI TO CHAR10O WS-GUESS(10:1)
                   END-IF
                END-PERFORM

            END-IF
           .
      ****************************************************************
      *F CHECK RESULT SECTION                                        *
      ****************************************************************
       FB-DRAW-HANGMAN SECTION.
           EVALUATE WS-COUNTER1
             WHEN 1  MOVE '- - -' TO HBASEO
             WHEN 2  MOVE '|'     TO HLINE5O
             WHEN 3  MOVE '|'     TO HLINE4O
             WHEN 4  MOVE '|'     TO HLINE3O
             WHEN 5  MOVE '|'     TO HLINE2O
             WHEN 6  MOVE '_____' TO HVLINEO
             WHEN 7  MOVE '|'     TO HLINE1O
             WHEN 8  MOVE 'O'     TO HHEADO
             WHEN 9  MOVE '/|\'   TO HLHANDO
             WHEN 10 MOVE '/'     TO HLFOOT1O
                     MOVE '\'     TO HLFOOT2O
           END-EVALUATE
           .
      ****************************************************************
      *F CHECK RESULT SECTION                                        *
      ****************************************************************
       FC-CHECK-WINLOSS SECTION.

             EVALUATE TRUE
              WHEN WS-GUESS = WORD
                 MOVE 'YOU WIN!' TO MSG5O
                 PERFORM X-EXIT
                 MOVE DFHPROTN TO INPUTA
              WHEN WS-COUNTER1 = 10
                 MOVE 'GAME OVER' TO MSG4O
                 MOVE WORD TO MSG3O
                 PERFORM X-EXIT
                 MOVE DFHPROTN TO INPUTA
             END-EVALUATE
             .
      ****************************************************************
      *Q DB2 SECTION                                                 *
      ****************************************************************
       QA-MAXWORD SECTION.
           INITIALIZE WORDID
           EXEC SQL
             SELECT  MAX(WORDID)
             INTO   :WORDID
             FROM USER11.WORDSDB2
           END-EXEC
           IF SQLCODE = 100
           MOVE 'SELECT MAX NOT SUCCESFUL' TO MSG1O
             PERFORM X-EXIT
           END-IF
           MOVE WORDID TO NUMWORDSO
           .

       QB-RANDOMIZE SECTION.
           INITIALIZE WS-RANDOMID WS-RANDOMNR
           EXEC SQL
             SELECT  RAND()
             INTO   :WS-RANDOMNR
             FROM USER11.WORDSDB2
             FETCH FIRST 1 ROW ONLY
           END-EXEC

           EVALUATE TRUE
           WHEN SQLCODE = 100
             MOVE 'RAND SELECT NOT SUCCESFUL' TO MSG1O
             PERFORM X-EXIT
           END-EVALUATE
           COMPUTE WS-RANDOMID = (WS-RANDOMNR * WORDID)
      *    MOVE WS-RANDOMID TO MSG2O
           IF WS-RANDOMID = 0
             MOVE 1 TO WS-RANDOMID
           END-IF
           .

       QC-SELECT SECTION.
           INITIALIZE WORD
           EXEC SQL
             SELECT  WORD
             INTO   :WORD
             FROM USER11.WORDSDB2
             WHERE WORDID = :WS-RANDOMID
           END-EXEC

           EVALUATE TRUE
           WHEN SQLCODE = 100
             MOVE 'SELECT NOT SUCCESFUL' TO MSG1O
             PERFORM X-EXIT
           END-EVALUATE
      *    MOVE WORD TO MSG1O
           .

       QD-MAPATTR SECTION.
           INITIALIZE WS-WORD-LENGTH
           MOVE 0 TO WS-WORD-TEMP
           INSPECT WORD TALLYING WS-WORD-TEMP FOR ALL ' '
           COMPUTE WS-WORD-LENGTH = WS-MAXCHAR - WS-WORD-TEMP
      *    MOVE WS-WORD-LENGTH TO MSG3O
      *    MOVE WS-WORD-LENGTH TO WORDLENO

           EVALUATE TRUE
            WHEN WS-WORD-LENGTH = 01
             MOVE DFHUNDLN TO CHAR1H
             MOVE DFHPROTN TO CHAR2A CHAR3A CHAR4A CHAR5A CHAR6A
                              CHAR7A CHAR8A CHAR9A CHAR10A

            WHEN WS-WORD-LENGTH = 02
             MOVE DFHUNDLN TO CHAR1H CHAR2H
             MOVE DFHPROTN TO CHAR3A CHAR4A CHAR5A CHAR6A CHAR7A
                              CHAR8A CHAR9A CHAR10A

            WHEN WS-WORD-LENGTH = 03
             MOVE DFHUNDLN TO CHAR1H CHAR2H CHAR3H
             MOVE DFHPROTN TO CHAR4A CHAR5A CHAR6A CHAR7A CHAR8A
                              CHAR9A CHAR10A

            WHEN WS-WORD-LENGTH = 04
             MOVE DFHUNDLN TO CHAR1H CHAR2H CHAR3H CHAR4H
             MOVE DFHPROTN TO CHAR5A CHAR6A CHAR7A CHAR8A CHAR9A
                              CHAR10A

            WHEN WS-WORD-LENGTH = 05
             MOVE DFHUNDLN TO CHAR1H CHAR2H CHAR3H CHAR4H CHAR5H
             MOVE DFHPROTN TO CHAR6A CHAR7A CHAR8A CHAR9A CHAR10A

            WHEN WS-WORD-LENGTH = 06
             MOVE DFHUNDLN TO CHAR1H CHAR2H CHAR3H CHAR4H CHAR5H
                              CHAR6H
             MOVE DFHPROTN TO CHAR7A CHAR8A CHAR9A CHAR10A

            WHEN WS-WORD-LENGTH = 07
             MOVE DFHUNDLN TO CHAR1H CHAR2H CHAR3H CHAR4H CHAR5H
                              CHAR6H CHAR7H
             MOVE DFHPROTN TO CHAR8A CHAR9A CHAR10A

            WHEN WS-WORD-LENGTH = 08
             MOVE DFHUNDLN TO CHAR1H CHAR2H CHAR3H CHAR4H CHAR5H
                              CHAR6H CHAR7H CHAR8H
             MOVE DFHPROTN TO CHAR9A CHAR10A

            WHEN WS-WORD-LENGTH = 09
             MOVE DFHUNDLN TO CHAR1H CHAR2H CHAR3H CHAR4H CHAR5H
                              CHAR6H CHAR7H CHAR8H CHAR9H
             MOVE DFHPROTN TO CHAR10A

            WHEN WS-WORD-LENGTH = 10
             MOVE DFHUNDLN TO CHAR1H CHAR2H CHAR3H CHAR4H CHAR5H
                              CHAR6H CHAR7H CHAR8H CHAR9H CHAR10H
            END-EVALUATE
              .

      ****************************************************************
      *X-EXIT SECTION                                                *
      ****************************************************************
       X-EXIT SECTION.
      *    STOP RUN
           EXIT PROGRAM
           .
