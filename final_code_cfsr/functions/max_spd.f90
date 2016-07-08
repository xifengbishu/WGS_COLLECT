 PROGRAM read_sfc_uv
   !
   implicit none
   !
   ! --- let this code allocatable !
   ! --- 16 Feb 2011.
   ! --------------------------------------------
   !
   integer :: kx, ky
   real    :: lon_beg, lon_end, lat_beg, lat_end, res, max_spd
   real, allocatable, dimension(:,:)  :: u, v
   integer :: k, j
   integer                           :: nargum, iargc
   character(len=100), dimension(10) :: argum
   character(len=4)                  :: year

    nargum=iargc()
    do k = 1, nargum
      call getarg(k,argum(k))
    enddo
    !
    if( nargum == 0 ) then
      write(*,*) ' Usage:  '
      write(*,*) '   plot_winds.exe YYYYMMDD_HH.sfc file_name'
      write(*,*) ' or  '
      write(*,*) '   plot_winds.exe YYYYMMDDHHSW.dat file_name'
      write(*,*) ' '
      stop
    endif 

   ! --- get dimension 
   open(1, file='dimension.dat', status='old')
     read(1,*) kx, ky, lon_beg, lon_end, lat_beg, lat_end, res
   close(1)

   ! --- read sfc_wind
   allocate( u(kx,ky), v(kx,ky) )
   open(1,file=trim(argum(1)))
     read(1,*) k, j
     read(1,*) u
     read(1,*) k, j
     read(1,*) v
   close(1)
   u = u * 1.08
   v = v * 1.08
   max_spd = SQRT( maxval( u*u + v*v ) )
   !print*,max_spd
   year=trim(argum(1))
   ! --- write out
   open(1, file='maxspd_'//year, action='write',position='append' )
     write(1,'(a11,F7.3)') trim(argum(1)), max_spd
   close(1)


 END PROGRAM read_sfc_uv
