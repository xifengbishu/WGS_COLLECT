
  PROGRAM plot_winds
    !
    ! --- REGRID/MM5 gives us sea surface winds 
    ! --- They are in ASCII format
    ! --- This code will employ GrADS to plot them
    integer                           :: nargum, iargc, k
    character(len=100), dimension(10) :: argum

    nargum=iargc()
    do k = 1, nargum
      call getarg(k,argum(k))
    enddo
    !
    write(*,*) ''
    write(*,*) ' ======================================'
    write(*,*) '  To plot sea surface winds from'
    write(*,*) '  REGRID/MM5 in ASCII long-lati Grid! '
    write(*,*) ''
    write(*,*) '   WGS, 09 April 2005.'
    write(*,*) ' ======================================'
    write(*,*) ''
    if( nargum == 0 ) then
      write(*,*) ' Usage:  '
      write(*,*) '   plot_winds.exe YYYYMMDD_HH.sfc file_name'
      write(*,*) ' or  '
      write(*,*) '   plot_winds.exe YYYYMMDDHHSW.dat file_name'
      write(*,*) ' '
      stop
    endif 
    open(1,file=trim(argum(1)),status = 'old',action='read')
        nline = 0
        do while (nline>=0)
          read(1,*,end=543)
            nline=nline+1
        enddo
543     print*,nline
      rewind(1)
      allocate ( spd(nline) )
      do i = 1 ,nline
       read(1,'(a18,a50)') sfc_year,sfc_file(i)
      enddo
    close(1)
    month_day(1:12)=(/31,28,31,30,31,30,31,31,30,31,30,31/)
    if (mod(year,4)==0.and.mod(year,100)/=0.or.mod(year,400)==0) then 
       month_day(2)=29
    else
       month_day(2)=28
    endif
    !
    ! === Step 2: read input file
  END PROGRAM plot_winds
