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
   integer :: k, i, j, nline, year, temp_same, ww
   integer                           :: nargum, iargc
   character(len=100), dimension(10) :: argum
   integer,parameter                 :: time_int=8,out_num=30,pick_num=40
   integer                           :: day_num
   integer,allocatable,dimension(:)  :: ty_month,ty_day,case_month,case_day
   integer,allocatable,dimension(:)  :: ty_month_head,ty_day_head,case_month_head,case_day_head
   integer,allocatable,dimension(:)  :: ty_month_tail,ty_day_tail,case_month_tail,case_day_tail
   real, allocatable, dimension(:)   :: day_spd
   character(len=8), allocatable, dimension(:)   :: case_time,ty_time,right_time
   !character(len=8), dimension(:)                :: 
   character(len=8)                              :: temp_time
   real, dimension(:)                :: int_spd(time_int)
   integer,dimension(12)             :: month_day
   

    nargum=iargc()
    do k = 1, nargum
      call getarg(k,argum(k))
    enddo
    !
    if( nargum == 0 ) then
      write(*,*) ' Usage:  '
      write(*,*) '   plot_winds.exe YYYYMMDD_HH.sfc file_name'
      write(*,*) ' or  '
      write(*,*) '   pick_spd.exe 2009'
      write(*,*) ' '
      stop
    endif 

    month_day(1:12)=(/31,28,31,30,31,30,31,31,30,31,30,31/)
    read(argum(1),'(i4)') year

    if (mod(year,4)==0.and.mod(year,100)/=0.or.mod(year,400)==0) then 
       month_day(2)=29
    else
       month_day(2)=28
    endif
    
    open(1,file='TYPHOON_case/TY_case_'//trim(argum(1)),status = 'old',action='read')
        nline = 0
        do while (nline>=0)
          read(1,*,end=543)
            nline=nline+1
        enddo
543      rewind(1)
      allocate ( ty_time(nline),ty_month(nline),ty_day(nline))
      allocate ( ty_month_head(nline),ty_day_head(nline))
      allocate ( ty_month_tail(nline),ty_day_tail(nline))
      do i = 1,nline
        read(1,*) ty_time(i)
        read(ty_time(i)(5:6),*) ty_month(i)
        read(ty_time(i)(7:8),*) ty_day(i)
        !
        ty_month_head(i) = ty_month(i)
        ty_day_head(i) = ty_day(i)-1
        if ( ty_day(i) == 1 ) then
           ty_month_head(i)=ty_month(i)-1
           ty_day_head(i)=month_day(ty_month_head(i) )
        endif
        !
        ty_month_tail(i) = ty_month(i)
        ty_day_tail(i) = ty_day(i)+1
        if ( ty_day(i) == month_day(ty_month(i)) )then
           ty_day_tail(i)=1
           ty_month_tail(i)=ty_month(i)+1
        endif
        !
      enddo
    close(1)
    open(1,file=trim(argum(1))//'_casetime',status = 'old',action='read')
      allocate ( case_time(pick_num),case_month(pick_num),case_day(pick_num))
      allocate ( case_month_head(pick_num),case_day_head(pick_num))
      allocate ( case_month_tail(pick_num),case_day_tail(pick_num))
      do i = 1,pick_num
        read(1,*) case_time(i),temp_spd
        read(case_time(i)(5:6),*) case_month(i)
        read(case_time(i)(7:8),*) case_day(i)
        !
        case_month_head(i) = case_month(i)
        case_day_head(i) = case_day(i)-1
        if ( case_day(i) == 1 ) then
           case_month_head(i)=case_month(i)-1
           case_day_head(i)=month_day(case_month_head(i) )
        endif
        !
        case_month_tail(i) = case_month(i)
        case_day_tail(i) = case_day(i)+1
        if ( case_day(i) == month_day(case_month(i)) )then
           case_day_tail(i)=1
           case_month_tail(i)=case_month(i)+1
        endif
        !
      enddo
    close(1)
    !
    ! --- Step 2
    !
    do i = 1,nline
    do j = 1,pick_num
       if (ty_month(i)==case_month(j) .and. ty_day(i) == case_day(j) ) then
          case_month(j)=99
          case_day(j) =99
       else if (ty_month_head(i)==case_month(j) .and. ty_day_head(i) == case_day(j) ) then
          case_month(j)=99
          case_day(j) =99
       else if (ty_month_tail(i)==case_month(j) .and. ty_day_tail(i) == case_day(j) ) then
          case_month(j)=99
          case_day(j) =99
       endif
    enddo
    enddo

    do i = 1,pick_num-1
    do j = i,pick_num
       if (case_month_head(i)==case_month(j) .and. case_day_head(i) == case_day(j) ) then
          case_month(j)=99
          case_day(j) =99
       else if (case_month_tail(i)==case_month(j) .and. case_day_tail(i) == case_day(j) ) then
          case_month(j)=99
          case_day(j) =99
       endif 
    enddo
    enddo
    open(1,file='temp_'//trim(argum(1)),action='write')
    do i = 1,pick_num
       if ( case_month(i) /= 99 ) then
          write(1,*) case_time(i)
       endif
    enddo
    close(1)

    ww = out_num-nline
    allocate ( right_time(ww))
    open(1,file='temp_'//trim(argum(1)),action='read')
      do i = 1,ww
         read(1,*) right_time(i)
      enddo
    close(1)
    !
    ! --- Step 3
    !
    open(1,file='recom_'//trim(argum(1))//'_case',action='write',position='append')
      do i = 1,nline
         write(1,*) ty_time(i)
      enddo
      do j = 1,out_num-nline
         write(1,*) right_time(j)
      enddo
    close(1)
 END PROGRAM read_sfc_uv
