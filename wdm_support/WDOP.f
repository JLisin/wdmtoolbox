      
      
      
      subroutine concatic(n, filename)
            !Jack Lisin, 11/05/2019
            !purpose::append filename with integer value
            implicit none
            character(len=*),intent(inout)::filename
            integer, intent(in):: n
            character(len=len_trim(filename))::dummyc

            write(dummyc,'(a15)')filename
            write(filename,'(a15,i0)')dummyc, n
      end subroutine 



      subroutine file_check(filename,WDMSFL)
          !Jack Lisin, 11/05/2019
          implicit none
          integer,intent(in)::WDMSFL
          character(len=50),intent(inout)::filename
          integer::n
          logical :: file_exists
          
          interface
                  subroutine concatic(n, filename)
                      implicit none
                      character(len=*),intent(inout)::filename
                      integer, intent(in):: n
                  end subroutine
          end interface
                    
          inquire(file=filename, exist=file_exists)
          
          if(file_exists) then
                n=1
                do  
                    call concatic(n,filename)
                    inquire(file=filename, exist=file_exists)
                    if(file_exists) then
                        n=n+1
                    else
                          open (unit=WDMSFL, file=filename,
     1    status='REPLACE', form='UNFORMATTED', access='DIRECT', recl=4)
                          exit
                    end if
                end do
          else
                open (unit=WDMSFL, file=filename,
     1    status='REPLACE', form='UNFORMATTED', access='DIRECT', recl=4)
          end if
          
      end subroutine!!!!!!!!!!!!!!!!!!!!!
      
        
      SUBROUTINE   WDBOPN
     I                    (WDMSFL,WDNAME,RONWFG,
     O                     RETCOD)
C
C     + + + PURPOSE + + +
C     Open a WDM file.  File is opened as new or old, depending on
C     the value of RONWFG.  The common block related to the WDM record
C     buffer are initialized the first time this routine is called.

      interface!!!!!!!!!!!!!!!!!!!!!
          !Jack Lisin, 11/05/2019
          
            subroutine file_check(filename, WDMSFL)
                implicit none
                integer,intent(in)::WDMSFL
                character(len=50),intent(inout)::filename
            end subroutine
                
      end interface
      character(len=50)::filename
      character(len=100)::cmd!!!!!!!!!!!!!!!!!!!!!

C
C     + + + DUMMY ARGUMENTS + + +
      INTEGER      WDMSFL,RONWFG,RETCOD
      CHARACTER(LEN=*) WDNAME
C
C     + + + ARGUMENT DEFINITIONS + + +
C     WDMSFL - Fortran unit number of the WDM file
C     WDNAME - name of the WDM file
C     RONWFG - read only/new file flag
C              0- normal open of existing WDM file,
C              1- open WDM file as read only (system dependent),
C              2- open new WDM file
C     RETCOD - return code
C               0 - successful open
C               1 - successful open, but invalid WDM file
C              <0 - error on open, -IOSTAT, compiler specific
C
C     + + + SAVES + + +
      INTEGER   INITFG
      SAVE INITFG
      INTEGER   RECRDL
      SAVE RECRDL
C
C     + + + LOCAL VARIABLES + + +
      INTEGER(4)IOS
C
C     + + + EXTERNALS + + +
      EXTERNAL   WDBFIN, WDFLCK, WDCREA
C
C     + + + DATA INITIALIZATIONS + + +
      DATA INITFG/0/
      DATA RECRDL/0/
C
C     + + + END SPECIFICATIONS + + +
C
      RETCOD= 0
C
      IF (RECRDL.EQ.0) THEN
C       first time called, determine compiler flag specific
C       definition of RECL units in OPEN
C
C       create a small file and try to write different size strings
!        OPEN(UNIT=WDMSFL,STATUS='SCRATCH',ACCESS='DIRECT',
!     1       FORM='UNFORMATTED',RECL=4)
          !!!!!!!!!!!!!!!!!!!!!
          !Jack Lisin, 11/05/2019
   
          filename='temporary.wdm01'
          call file_check(filename,WDMSFL)
          !!!!!!!!!!!!!!!!!!!!!

        WRITE(WDMSFL,REC=1,ERR=110) '1234567890123456'
        RECRDL= 512
        GOTO 100
 110    CONTINUE
        WRITE(WDMSFL,REC=1,ERR=120) '12345678'
        RECRDL= 1024
        GOTO 100
 120    CONTINUE
        WRITE(WDMSFL,REC=1,ERR=100) '1234'
        RECRDL= 2048
 100    CONTINUE
        CLOSE(WDMSFL,STATUS='DELETE')
      END IF
C
      IF (RONWFG.EQ.1) THEN
C       open file as 'read only'
        OPEN (UNIT=WDMSFL,FILE=WDNAME,STATUS='OLD',
     1        ACCESS='DIRECT',FORM='UNFORMATTED',RECL=RECRDL,
     2        ERR=10,IOSTAT=IOS)
      ELSE IF (RONWFG.EQ.2) THEN
C       open new wdm file
        OPEN (UNIT=WDMSFL,FILE=WDNAME,STATUS='NEW',
     1        ACCESS='DIRECT',FORM='UNFORMATTED',RECL=RECRDL,
     2        ERR=10,IOSTAT=IOS)
      ELSE
C       open file w/out 'read only'
        OPEN (UNIT=WDMSFL,FILE=WDNAME,STATUS='OLD',
     1        ACCESS='DIRECT',FORM='UNFORMATTED',RECL=RECRDL,
     2        ERR=10,IOSTAT=IOS)
      END IF
C     WDM file opened successfully
      IF (INITFG.EQ.0) THEN
C       first time called, initialize WDM record buffer
        CALL WDBFIN
        INITFG= 1
      END IF
      IF (RONWFG.EQ.2) THEN
C       new file, need to initialize it
        CALL WDCREA (WDMSFL)
      END IF
      IF (RETCOD.EQ.0) THEN
C       check WDM directory records
        CALL WDFLCK (WDMSFL,
     O               RETCOD)
      END IF
      GO TO 20
 10   CONTINUE
C       error on open, exact value of retcod may vary by system,
C       set it to a negative value for consistancy
        RETCOD= IOS
        IF (RETCOD.GT.0) RETCOD= -RETCOD
        IF (RETCOD.EQ.0) RETCOD= -1
 20   CONTINUE
 
      close(WDMSFL)
      write(cmd,'("del.sh ",a50)')filename
      call system(cmd)
C
      RETURN
      END
