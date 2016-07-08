 PROGRAM read_sfc_uv
   !
   implicit none
   !
   ! --- let this code allocatable !
   ! --- 16 Feb 2011.
   ! --------------------------------------------
   !
   real    :: temp_spd
   real, allocatable, dimension(:)   :: spd
   character(len=11), allocatable, dimension(:)   :: spd_time
   integer :: k, i, j, nline
   integer                           :: nargum, iargc
   character(len=100), dimension(10) :: argum
   character(len=4)                  :: year
   integer,parameter                 :: time_int=8,out_num=40
   integer                           :: day_num
   real, allocatable, dimension(:)   :: day_spd
   character(len=8), allocatable, dimension(:)   :: date_time
   character(len=8)                              :: temp_time
   real, dimension(:)                :: int_spd(time_int)

    nargum=iargc()
    do k = 1, nargum
      call getarg(k,argum(k))
    enddo
    !
    if( nargum == 0 ) then
      write(*,*) ' Usage:  '
      write(*,*) '   plot_winds.exe YYYYMMDD_HH.sfc file_name'
      write(*,*) ' or  '
      write(*,*) '   pick_spd.exe maxspd_2009'
      write(*,*) ' '
      stop
    endif 


    open(1,file=trim(argum(1)),status = 'old',action='read')
        nline = 0
        do while (nline>=0)
          read(1,*,end=543)
            nline=nline+1
        enddo
543      rewind(1)
      allocate ( spd(nline) ,spd_time(nline))
      do i = 1,nline
        read(1,*) spd_time(i),spd(i)
      enddo
    close(1)
    !
    ! --- Step 2 : day spd
    !
    day_num=nline/time_int
    allocate ( day_spd(day_num),date_time(day_num) )
    do i = 1,nline,time_int
       k = (i-1)/time_int+1
    do j = 1,time_int
       int_spd(j) = spd(i+j-1)
    enddo
    day_spd(k) = maxval(int_spd)
    enddo

    do i = 1,day_num
       k = (i-1)*8+1
       date_time(i) = spd_time(k)
       !print*,date_time(i),day_spd(i)
    enddo
    !
    ! --- Step 3 : paixu
    !
    do i = 1,day_num-1
    !   k = (i-1)*8+1
    do j = i,day_num
       if ( day_spd(i) < day_spd(j) ) then
         temp_spd = day_spd(i)
         temp_time=date_time(i)  
  
         day_spd(i) = day_spd(j)
         date_time(i)=date_time(j)

         day_spd(j) = temp_spd
         date_time(j)=temp_time
       endif
    enddo
    enddo
    !print*,day_spd,date_time
    !
    ! --- Step 4 : output
    !
    do i = 1, out_num
       print*, date_time(i), day_spd(i)
    enddo
 END PROGRAM read_sfc_uv
