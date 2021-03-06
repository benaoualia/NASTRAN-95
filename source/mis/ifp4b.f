      SUBROUTINE IFP4B (FILE,SCRT,ANY,SPACE,LSPACE,RECID,EOF)
C
C     THIS ROUTINE, CALLED BY IFP4, COPIES DATA FROM -FILE- TO -SCRT-
C     UP TO THE -RECID- SPECIFIED IF IT EXISTS AND COPIES THE -RECID-
C     IN ANY EVENT.  -ANY- IS SET TRUE IF THE -RECID- WAS FOUND.
C     -EOF- IS SET TRUE AS SOON AS AN END OF FILE IS HIT ON -FILE-.
C     -SPACE- IS A WORKING AREA OF LENGTH -LSPACE-.  IF RECID(1) = -1,
C     THE BALANCE OF -FILE- IS COPIED TO -SCRT- AND THEN -FILE- IS
C     REWOUND AND -SCRT- IS COPIED BACK ONTO -FILE-.  BOTH FILES ARE
C     THEN CLOSED.
C
      LOGICAL         EOF,ANY,BIT,NOGO
      INTEGER         FILE,SCRT,SPACE(5),RECID(2),OUTPUT,NAME(2),SYSBUF,
     1                FLAG,BUF1,BUF2,REC(3),ILIMIT(3),EOR
      CHARACTER       UFM*23
      COMMON /XMSSG / UFM
      COMMON /SYSTEM/ SYSBUF,OUTPUT,NOGO
      COMMON /NAMES / RD,RDREW,WRT,WRTREW,CLSREW,CLS
      DATA    NAME  , NOEOR,EOR  /4HIFP4,4HB   ,0,1/,
     1        ILIMIT/ 3*2147483647 /
C
      IF (RECID(1) .EQ. -1) GO TO 3000
      ANY = .FALSE.
C
C     CHECK TRAILER BIT TO SEE IF RECORD EXISTS
C
      CALL IFP4F (RECID(2),FILE,BIT)
      IF (.NOT.BIT) GO TO 2000
      IF (EOF) GO TO 5001
C
C     READ A 3-WORD RECORD ID
C
      ANY = .TRUE.
      IFILE = FILE
  650 CALL READ  (*5001,*6002,FILE,REC(1),3,NOEOR,FLAG)
      CALL WRITE (SCRT,REC,3,NOEOR)
      IF (REC(1) .EQ. RECID(1)) RETURN
C
C     NOT THE CORRECT RECORD, THUS COPY BALANCE OF RECORD OVER.
C
  750 CALL READ  (*6001,*800,FILE,SPACE,LSPACE,NOEOR,FLAG)
      CALL WRITE (SCRT,SPACE,LSPACE,NOEOR)
      GO TO 750
  800 CALL WRITE (SCRT,SPACE,FLAG,EOR)
      GO TO 650
C
C     RECORD DOES NOT CURRENTLY EXIST, THUS START ONE
C
 2000 CALL WRITE (SCRT,RECID,2,NOEOR)
      CALL WRITE (SCRT,0,1,NOEOR)
C
C     PUT BIT IN TRAILER
C
      CALL IFP4G (RECID(2),FILE)
      RETURN
C
C     WRAP UP FILES
C
 3000 IF (EOF) GO TO 3400
 3100 CALL READ  (*3500,*3200,FILE,SPACE,LSPACE,NOEOR,FLAG)
      CALL WRITE (SCRT,SPACE,LSPACE,NOEOR)
      GO TO 3100
 3200 CALL WRITE (SCRT,SPACE,FLAG,EOR)
      GO TO 3100
 3400 CALL WRITE (SCRT,ILIMIT,3,EOR)
C
C     FILE IS ALL COPIED TO SCRT.  REWIND AND RETURN.
C
 3500 EOF = .TRUE.
      CALL CLOSE (SCRT,CLSREW)
      CALL CLOSE (FILE,CLSREW)
C
C     COPY DATA FROM SCRT TO FILE.
C
      BUF1 = 1
      BUF2 = SYSBUF + 2
      I    = 2*SYSBUF + 4
      J    = LSPACE - I
      IF (I .GT. LSPACE) CALL MESAGE (-8,0,NAME)
      IFILE = FILE
      CALL OPEN (*6003,FILE,SPACE(BUF1),WRTREW)
      IFILE = SCRT
      CALL OPEN  (*6003,SCRT,SPACE(BUF2),RDREW)
 3800 CALL READ  (*4000,*3900,SCRT,SPACE(I),J,NOEOR,FLAG)
      CALL WRITE (FILE,SPACE(I),J,NOEOR)
      GO TO 3800
 3900 CALL WRITE (FILE,SPACE(I),FLAG,EOR)
      GO TO 3800
 4000 CALL CLOSE (SCRT,CLSREW)
      CALL CLOSE (FILE,CLSREW)
      RETURN
C
C     ERROR CONDITIONS
C
 5001 NOGO = .TRUE.
      WRITE  (OUTPUT,5002) UFM,RECID(1),RECID(2),FILE
 5002 FORMAT (A23,' 4056, RECORD ID =',2I10,' IS OUT OF SYNC ON DATA ',
     1       'BLOCK NUMBER',I10, /5X,'AN IFP4 SYSTEM ERROR.')
      EOF = .TRUE.
      RETURN
C
 6001 CALL MESAGE (-2,IFILE,NAME)
 6002 CALL MESAGE (-3,IFILE,NAME)
 6003 CALL MESAGE (-1,IFILE,NAME)
      RETURN
      END
