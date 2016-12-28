      SUBROUTINE WAVEY (IG,ILD,NEW,NC,IC,KACT,MAXB,MAXW,AVERW,SUMW,
     1                  RMS,BRMS,JG)
C
C     THIS ROUTINE IS USED ONLY IN BANDIT MODULE
C
C     COMPUTE WAVEFRONT AND ACTIVE COLUMN DATA -
C     MAXIMUM WAVEFRONT, AVERAGE WAVEFRONT, SUM OF ROW WAVEFRONTS,
C     SUM OF SQUARES OF ROW WAVEFRONTS, RMS WAVEFRONT, AND BANDWIDTH,
C     RMS BANDWIDTH, AND MINIMUM NODAL DEGREE.
C     DIAGONAL TERMS ARE INCLUDED.
C
C     IG     = CONNECTION TABLE
C     ILD(I) = NEW LABEL FOR NODE WITH ORIGINAL INTERNAL LABEL I
C     NEW(I) = INTERNAL LABEL CORRESPONDING TO NEW LABEL I
C              NEW AND ILD ARE INVERSES OF EACH OTHER
C     NC     = COMPONENT ID
C              IF NC.LE.0, USE ALL COMPONENTS.
C     IC(I)  = COMPONENT INDEX FOR ORIGINAL NODE I.
C     KACT(I)= LIST OF ACTIVE COLUMN FLAGS (UPDATED FOR EACH ROW)
C            = 1 IF COL I IS ACTIVE AT GIVEN ROW
C     MAXB   = BANDWIDTH
C     MAXW   = MAXIMUM WAVEFRONT
C     AVERW  = AVERAGE WAVEFRONT
C     SUMW   = SUM OF ROW WAVEFRONTS
C     SUMSQ  = SUM OF SQUARES OF ROW WAVEFRONTS
C     BSUMSQ = SUM OF SQUARES OF ROW BANDWIDTHS
C     RMS    = RMS WAVEFRONT
C     BRMS   = RMS BANDWIDTH
C     JG     = SCRATCH SPACE FOR BUNPAK
C     NN     = NUMBER OF NODES
C     MM     = MAX NODAL DEGREE
C     MINDEG = MINIMUM NODAL DEGREE
C
C     INPUT  - IG,ILD,NN,MM,NC,IC.
C     OUTPUT - NEW,KACT,MAXW,AVERW,SUMW,RMS,MAXB,BRMS,MINDEG
C
      INTEGER          SUMW
      DOUBLE PRECISION SUMSQ,    BSUMSQ
      DIMENSION        IC(1),    ILD(1),   NEW(1),   KACT(1),  IG(1),
     1                 JG(1)
      COMMON /BANDS /  NN,       MM,       DUM6S(6), MINDEG
C
C     INITIALIZE WAVEFRONT DATA.
C
      MAXB  = 0
      MAXW  = 0
      SUMW  = 0
      SUMSQ = 0.D0
      BSUMSQ= 0.D0
      AVERW = 0.
      RMS   = 0.
      MINDEG= MIN0(MINDEG,MM)
      IF (NN*MM .LE. 0) RETURN
C
C     INITIALIZE NEW, THE INVERSE OF ILD
C
      IF (NC .GT. 0) GO TO 8
      DO 5 I = 1,NN
      K = ILD(I)
      IF (K .LE. 0) GO TO 5
      NEW(K) = I
    5 CONTINUE
C
C     INITIALIZE ACTIVE COLUMN FLAGS (1 FOR ACTIVE)
C
    8 DO 10 I = 1,NN
   10 KACT(I) = 0
C
C     COMPUTE WAVEFRONT DATA.
C
      IWAVE = 1
      KT = 0
      DO 40 I = 1,NN
C
C     COMPUTE NUMBER OF ACTIVE COLUMNS FOR ROW I
C
      K = NEW(I)
      IF (NC) 18,18,15
   15 IF (K .LE. 0) GO TO 40
      IF (NC-IC(K)) 40,18,40
   18 KT = KT + 1
      CALL BUNPAK(IG,K,MM,JG)
      IB = 0
      DO 20 J = 1,MM
      L = JG(J)
      IF (L .EQ. 0) GO TO 30
      M  = ILD(L)
      IB = MAX0(IB,I-M)
      IF (M .LE. I) GO TO 20
      IF (KACT(M) .EQ. 1) GO TO 20
      IWAVE = IWAVE + 1
      KACT(M) = 1
   20 CONTINUE
      GO TO 35
   30 CONTINUE
      MINDEG = MIN0(MINDEG,J-1)
   35 CONTINUE
C
C     IB1 = ROW BANDWIDTH FOR ROW I (DIAGONAL INCLUDED)
C
      IB1 = IB + 1
      MAXB = MAX0(MAXB,IB1)
      IF (KACT(I) .EQ. 1) IWAVE = IWAVE - 1
C
C     IWAVE = CURRENT NUMBER OF ACTIVE COLUMNS FOR ROW I
C             (DIAGONAL INCLUDED)
C
      MAXW  = MAX0(MAXW,IWAVE)
      SUMW  = SUMW + IWAVE
      WAVE  = FLOAT(IWAVE)
      SUMSQ = SUMSQ + WAVE*WAVE
      WAVE  = FLOAT(IB1)
      BSUMSQ= BSUMSQ + WAVE*WAVE
C
   40 CONTINUE
C
      ANN   = FLOAT(KT)
      AVERW = FLOAT(SUMW)/ANN
      RMS   = SQRT(SNGL( SUMSQ)/ANN)
      BRMS  = SQRT(SNGL(BSUMSQ)/ANN)
      RETURN
      END