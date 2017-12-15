function [data,header]=read_grads(file_name,var_name,varargin)
% [var,header]=read_grads(file_name,var_name) is a function to read
% in binary files using their GrADS descriptor header. 
% If var_name is 'all' or non-existent, all variables are read and 
% sent to the base-workspace.
% Please check before-hand the data-type (big/little endian), as well
% as the data precision (single/double...), and adjust if necessary 
% the header at the beginning of read_grads.m.
% Optionally, you can improve the indications from the header file in 
% the sub-function grads_name (hereafter).
% 
% Kristof Sturm, sturm@dkrz.de or sturm@lgge.obs.ujf-grenoble.fr, 29.10.02

global l_quiet

n=strmatch('quiet',{varargin{1:2:end}});
if isempty(n)
  l_quiet=0;
else
  switch lower(varargin{2*(n-1)+2})
   case {1,'yes'}
    l_quiet=1;
   case {0,'no'}
    l_quiet=0;
  end
end

header=struct('FILENAME',file_name,...
	      'VARSIZE',{[]},...
	      'NVAR',0,...
	      'DATANAME','-',...
	      'FID',{[]},...
	      'BINTYPE','-',...
	      'BINPRECISION','float32',...
	      'DSET','-',...
	      'DTYPE',1,...
	      'INDEX','-',...
	      'TITLE','-',...
	      'UNDEF',0,...
	      'OPTIONS',{[]},...
	      'XDEF',{[]},...
	      'YDEF',{[]},...
	      'ZDEF',{[]},...
	      'TDEF',{[]},...
	      'VARS',struct([]),...
	      'FILEHEADER',0,...
	      'THEADER',0,...
	      'XYHEADER',0);

header.XDEF.rev=0;
header.YDEF.rev=0;
header.ZDEF.rev=0;

% [comp,max_size,endian]=computer;
endian='L';
if endian=='L'
  header.BINTYPE='ieee-le'; 
elseif endian=='B'
  header.BINTYPE='ieee-be';
end

data=[];

file_name=deblank(file_name);
if exist(file_name,'file')
  fid_ctl = fopen(file_name,'r');
  % disp(['CTL opened: ',num2str(fid_ctl)])
  % [header.FID]=deal([fid_ctl 0]);
  header(1).FID{1}=fid_ctl;
  if isunix, sep='/';
  else
    sep='\\';
  end
  if ~isempty(strfind(file_name,sep))
    slash=max(strfind(file_name,sep));
    header(1).DIR=file_name(1:slash);
    file_name=file_name((slash+1):end);
  end
  header(1).FILENAME=file_name;
else
  error(['Inexistent header file ',file_name])
end

% Enabling read_grads to handle netcdf files. 

point=strfind(file_name,'.');
suf=lower(file_name(point(end)+1:end));

if strcmp(suf,'ctl')
% reading the .ctl file : 
while ~feof(fid_ctl)
  line=fgets(fid_ctl);
  if isempty(line(1:end-1)), break, end
  % cutting the line into words.
  line_gaps=isspace(line);
  % removing consecutive blancks.
  while line_gaps(1)==1, line_gaps(1)=[]; line(1)=[]; end
  if line(1)=='*'
    if ~l_quiet
      disp(line)
    end
  else
    no_gaps=0;
    while ~no_gaps
      line_gap2=find(line_gaps);
      if any(diff(line_gap2)==1)
	dup=1+find(diff(line_gap2)==1);
	line_gaps(line_gap2(dup))=[];
	line(line_gap2(dup))=[];
      else
	no_gaps=1;
      end
    end
    entry=line(1:(min(find(line_gaps))-1));
    words={''};
    for n=1:(sum(line_gaps)-1)
      words{n}=line((line_gap2(n)+1):(line_gap2(n+1)-1));
    end
    header=read_header(entry,words);
    % disp(words)
  end
end

% Opening the binary file for later reading:
fid_bin = fopen(header.DATANAME,'r', header.BINTYPE );
% disp(['BIN opened: ',num2str(fid_bin)])
[header(1).FID] = {fid_ctl, fid_bin};

fclose(fid_ctl);
nvar=size(header.VARS,1);
header.NVAR=nvar;

if nargin>1 & isempty(var_name)
  if ~l_quiet
    disp(['Header for ',header.FILENAME,' read.'])
  end
  fclose(header.FID{2});
  return
end

if nargout==0
  assignin('caller','header',header)
  assignin('caller','vars',vars);
end

if header.DTYPE          % Gridded data set
  
  % Computing the size of each variable:
  var_size=zeros(nvar,4);  % array of the var. size [X,Y,Z,T]
  var_size(:,1)=header.XDEF.num;
  var_size(:,2)=header.YDEF.num;
  var_size(:,3)=cat(1,header.VARS.levs);
  var_size(:,4)=header.TDEF.num;
  header.VARSIZE={var_size};
  if exist('grads_name','file')
    [vars,header]=grads_name(header,vars);
  end
  
  % reading the bin. file :
  if nargin == 1 | strcmp(lower(var_name),'all')
    read_data(header);
  elseif nargin == 2
    t_limits=[1 header.TDEF.num];
    ivar=strmatch(var_name,{header.VARS.name},'exact');
    if isempty(ivar)
      if ~l_quiet
	disp(['The variable ',var_name,' cannot be found in ',header.DATANAME])
      end
      data=[];
      return
    end
    z_limits=[1 header.VARS(ivar).levs];
    y_limits=[1 header.YDEF.num];
    x_limits=[1 header.XDEF.num];
    data=read_var(header,var_name,t_limits,z_limits,y_limits,x_limits);
    header.XDEF.vec=header.XDEF.vec(x_limits(1):x_limits(2));
    header.XDEF.num=length(header.XDEF.vec);
    header.YDEF.vec=header.YDEF.vec(y_limits(1):y_limits(2));
    header.YDEF.num=length(header.YDEF.vec);
  else
    for n=1:2:nargin-2
      switch lower(varargin{n})
       case {'x'}
	x_limits=varargin{n+1};
       case {'lon'}
	lon_limits=sort(varargin{n+1});
	x_limits=interp1(header.XDEF.vec,1:header.XDEF.num,...
			 lon_limits,'nearest',NaN);
	if any(isnan(x_limits))
	  if ~l_quiet
	    disp(['The X-limits ',num2str(lon_limits),...
		  ' exceed the data coverage ',...
		  num2str(header.XDEF.vec([1 end]))])
	  end
	  data=[];
	  return
	end
       case {'y'}
	y_limits=varargin{n+1};
       case {'lat'}
	lat_limits=sort(varargin{n+1});
	y_limits=interp1(header.YDEF.vec,1:header.YDEF.num,...
			 lat_limits,'nearest',NaN);
	if any(isnan(y_limits))
	  if ~l_quiet
	    disp(['The Y-limits ',num2str(lat_limits),...
		  ' exceed the data coverage ',...
		  num2str(header.YDEF.vec([1 end]))])
	  end
	  data=[];
	  return
	end
	if header.YDEF.rev,
	  y_limits=header.YDEF.num*ones(size(y_limits))-fliplr(y_limits)+1;
	end
       case {'t','time'}
	t_limits=varargin{n+1};
       case {'z','lev'}
	z_limits=varargin{n+1};
	ivar=strmatch(var_name,{header.VARS.name},'exact');
	if isempty(ivar)
	  if ~l_quiet
	    disp(['The variable ',var_name,' cannot be found in ',header.DATANAME])
	  end
	  data=[];
	  return
	end
	if any(z_limits>header.VARS(ivar).levs)
	  if ~l_quiet
	    disp(['The variable ',var_name,' has only ',...
		  header.VARS(ivar).levs,' levels.'])
	  end
	  data=[];
	  return
	end
      end
    end
    if ~exist('t_limits','var'), t_limits=[1 header.TDEF.num]; end
    if ~exist('z_limits','var')
      ivar=strmatch(var_name,{header.VARS.name},'exact');
      if isempty(ivar)
	if ~l_quiet
	  disp(['The variable ',var_name,' cannot be found in ',header.DATANAME])
	end
	data=[];
	return
      end
      z_limits=[1 header.VARS(ivar).levs];
    end
    if ~exist('y_limits','var')
      y_limits=[1 header.YDEF.num];
    end
    if ~exist('x_limits','var')
      x_limits=[1 header.XDEF.num];
    end      
    data=read_var(header,var_name,t_limits,z_limits,y_limits,x_limits);
    header.XDEF.vec=header.XDEF.vec(x_limits(1):x_limits(2));
    header.XDEF.num=length(header.XDEF.vec);
    if header.YDEF.rev,
      y_limits=header.YDEF.num*ones(size(y_limits))-fliplr(y_limits)+1;
    end
    header.YDEF.vec=header.YDEF.vec(y_limits(1):y_limits(2));
    header.YDEF.num=length(header.YDEF.vec);
  end
  
  %    if header.XDEF.rev, header.XDEF.vec=header.XDEF.vec([end:-1:1]); end
  %    if header.YDEF.rev, header.YDEF.vec=header.YDEF.vec([end:-1:1]); end
  %    if header.ZDEF.rev, header.ZDEF.vec=header.ZDEF.vec([end:-1:1]); end
  
else                     % Station data set
  
  data=read_station(header);
  
end

fclose(header.FID{2});

elseif strcmp(suf,'nc') % Enabling NetCDF in read_grads, based on snctools
  old_dir=pwd;
  if isfield(header,'DIR')
    cd(header.DIR)
  end % if
  
  % Reading the header, conforming to GrADS conventions:
  ncheader=nc_info(file_name);
  
  header.FILENAME=ncheader.Filename;
  header.DATANAME=ncheader.Filename;
  header.NVAR=length(ncheader.DataSet);

  fields={{'lon','longitude','x','i'},'XDEF';
          {'lat','latitude','y','j'},'YDEF';
          {'lev','plev','nv','bnds'},'ZDEF';
          {'time','tps','t','l'},'TDEF'};
  for idim=1:size(fields,1)
    for dim=fields{idim,1}
      dim_id=strmatch(dim{1},{ncheader.DataSet.Name},'exact');
      if ~isempty(dim_id), break, end
    end % for
    if isempty(dim_id)
      disp(['Dim ',fields{idim,2},' is missing.'])
      vec=1;
      num=1;
      type='LINEAR';
    else
      num=ncheader.DataSet(dim_id).Size;
      vec=nc_varget(file_name,dim{1});
      if length(unique(diff(vec)))==1
        type='LINEAR';
      else
        type='LEVELS';
      end
      if all(diff(vec)<0)
        rev=1;
        vec=flipud(reshape(vec,[],1));
      elseif all(diff(vec)>0)
        rev=0;
      else
        error(['Unsuitable vector ',dim{1}])
      end
    end % if
    
    DEF=struct('num',num,'vec',vec,'type',type,'rev',rev);
    
    header=setfield(header,fields{idim,2},DEF);
  end % for idim

  for ivar=1:header.NVAR
    header.VARS(ivar).id=ivar;
    header.VARS(ivar).name=ncheader.DataSet(ivar).Name;
    header.VARS(ivar).size=ones(1,4);
    for idim=1:length(ncheader.DataSet(ivar).Dimension)
      [dim_id,j]=ind2sub(size(cat(1,fields{:,1})),...
                         strmatch(ncheader.DataSet(ivar).Dimension(idim),...
                             cat(1,fields{:,1}),'exact'));
      header.VARS(ivar).size(dim_id)=...
          getfield(eval(['header.',fields{dim_id,2}]),'num');
    end % for
    header.VARS(ivar).levs=header.VARS(ivar).size(3);
  end % for

  header.VARSIZE={cat(1,header.VARS.size)};
  
  if nargin==1 | isempty(var_name) | strcmp(var_name,'all')
    data=[];
    if exist('old_dir','var')
      cd(old_dir)
    end
    return
  end
  
  var_id=strmatch(var_name,{ncheader.DataSet.Name});
  if isempty(var_id)
    error(['Variable ',var_name,' is not available in ',file_name,...
           ': ',{ncheader.DataSet.Name}])
  end % if 
  
  for n=1:2:nargin-2
    switch lower(varargin{n})
     case {'x'}
      x_limits=varargin{n+1};
     case {'lon'}
      lon_limits=sort(varargin{n+1});
      x_limits=interp1(header.XDEF.vec,1:header.XDEF.num,...
                       lon_limits,'nearest',NaN);
      if any(isnan(x_limits))
        if ~l_quiet
          disp(['The X-limits ',num2str(lon_limits),...
                ' exceed the data coverage ',...
                num2str(header.XDEF.vec([1 end])')])
        end
        data=[];
        return
      end
     case {'y'}
      y_limits=varargin{n+1};
     case {'lat'}
      lat_limits=sort(varargin{n+1});
      y_limits=interp1(header.YDEF.vec,1:header.YDEF.num,...
                       lat_limits,'nearest',NaN);
      if any(isnan(y_limits))
        if ~l_quiet
          disp(['The Y-limits ',num2str(lat_limits),...
                ' exceed the data coverage ',...
                num2str(header.YDEF.vec([1 end])')])
        end
        data=[];
        return
      end
      if header.YDEF.rev,
        y_limits=header.YDEF.num*ones(size(y_limits))-fliplr(y_limits)+1;
      end
     case {'t','l','time'}
      t_limits=varargin{n+1};
     case {'z','k','lev'}
      z_limits=varargin{n+1};
      ivar=strmatch(var_name,{header.VARS.name},'exact');
      if isempty(ivar)
        if ~l_quiet
          disp(['The variable ',var_name,' cannot be found in ',header.DATANAME])
        end
        data=[];
        return
      end
      if any(z_limits>header.VARS(ivar).levs)
        if ~l_quiet
          disp(['The variable ',var_name,' has only ',...
                header.VARS(ivar).levs,' levels.'])
        end
        data=[];
        return
      end
    end % switch
  end % for
  
  if ~exist('t_limits','var'), t_limits=[1 header.TDEF.num]; end
  if ~exist('z_limits','var')
    ivar=strmatch(var_name,{header.VARS.name},'exact');
    if isempty(ivar)
      if ~l_quiet
        disp(['The variable ',var_name,' cannot be found in ',header.DATANAME])
      end
      data=[];
      return
    end
    z_limits=[1 header.VARS(ivar).levs];
  end % if
  if ~exist('y_limits','var')
    y_limits=[1 header.YDEF.num];
  end
  if ~exist('x_limits','var')
    x_limits=[1 header.XDEF.num];
  end      
  % data=read_var(header,var_name,t_limits,z_limits,y_limits,x_limits);
  % Retrieve the corresponding variable:
  
  if all(header.VARS(var_id).size([3 4])==[1 1])
    data=nc_varget(file_name,var_name,...
                   [y_limits(1),x_limits(1)]-1,...
                   diff(cat(1,y_limits,x_limits),1,2)'+1);
  elseif header.VARS(var_id).size(3)==1
    data=nc_varget(file_name,var_name,...
                   [t_limits(1),y_limits(1),x_limits(1)]-1,...
                   diff(cat(1,t_limits,y_limits,x_limits),1,2)'+1);
  elseif header.VARS(var_id).size(4)==1
    data=nc_varget(file_name,var_name,...
                   [z_limits(1),y_limits(1),x_limits(1)]-1,...
                   diff(cat(1,z_limits,y_limits,x_limits),1,2)'+1);
  else
    data=nc_varget(file_name,var_name,...
                   [t_limits(1),z_limits(1),y_limits(1),x_limits(1)]-1,...
                   diff(cat(1,t_limits,z_limits,y_limits,x_limits),1,2)'+1);
  end
  
  header.XDEF.vec=header.XDEF.vec(x_limits(1):x_limits(2));
  header.XDEF.num=length(header.XDEF.vec);
  if header.YDEF.rev,
    y_limits=header.YDEF.num*ones(size(y_limits))-fliplr(y_limits)+1;
  end 
  if diff(y_limits)<0, error('Unsuitable Y limits'), end
  header.YDEF.vec=header.YDEF.vec(y_limits(1):y_limits(2));
  header.YDEF.num=length(header.YDEF.vec);
  
  header.ZDEF.vec=z_limits(1):z_limits(2);
  header.ZDEF.num=diff(z_limits)+1;
  
  header.TDEF.vec=t_limits(1):t_limits(2);
  header.TDEF.num=diff(t_limits)+1;
  
  if length(size(data))==2
    data=permute(data,[2 1]);
  elseif length(size(data))==3 & header.ZDEF.num==1
    data=permute(data,[3 2 4 1]);
  elseif length(size(data))==3 & header.TDEF.num==1
    data=permute(data,[3 2 1]);
  elseif length(size(data))==4
    data=permute(data,[4 3 2 1]);
  end % if
  
  if header.YDEF.rev
    data=flipdim(data,2);
  end
  
  if exist('old_dir','var')
    cd(old_dir)
  end
else
  disp(['Suffix .',suf,' is not yet enabled.'])
end % if
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function header=read_header(entry,words)
% sets the header values according to what was read in the .ctl-file.
% cf. GrADS documentation : http://grads.iges.org/grads/gadoc/descriptorfile.html

global l_quiet

header=evalin('caller','header');
fid_ctl=header.FID{1};

grid_fields={'num','type','vec','rev'};

switch upper(entry)
 case 'DSET'                    % Name of the bin. data file.
  param=deal(words{1});
  if param(1)=='^' & isfield(header,'DIR')
    param(1)=[];
    param=[header.DIR,param];
  elseif param(1)=='^'
    param(1)=[];
  end
  if exist(param,'file')
    header.DATANAME=param; 
  else
    error(['Non-existent file ',param])
  end
  %
 case 'DTYPE'                  % Gridded or station data-file (not used later)
  param=lower(words{1});
  switch param
   case 'grib'
    header.DTYPE=1;
   case 'station'
    header.DTYPE=0;
  end
  %
 case 'STNMAP'                  % Name of the map file for station data (set in INDEX)
  if header.DTYPE
    warning([header.FILENAME,' cannot specify STNMAP=',param,' for a gridded data set.'])
  end
  param=deal(words{1});
  if param(1)=='^'
    param(1)=[];
  end
  if exist(param,'file')
    header.INDEX=param; 
  else
    error(['Non-existent file ',param])
  end
  %
 case 'INDEX'                  % Name of the GRIB map file (not used later)
  [header.INDEX]=strcat(words{:});
  %
 case 'TITLE'                  % Data title (not used later)
  line={words{:}};
  space=cell(size(line));
  [space{:}]=deal(char(32));
  line=cat(1,line,space);
  line=reshape(line,1,prod(size(line)));   % Rearranging the title to keep spaces between words.
  header.TITLE=deblank(cat(2,line{:}));
  %
 case 'UNDEF'                  % Missing or undefined data value
  param=words{1};
  if isreal(str2num(param))
    header(1).UNDEF=str2num(param);
  else
    error(['Wrong missing value format : ',param])
  end
  %
 case 'OPTIONS'                % Possible options (not all implemented...)
  for param=words
  param=param{1};
  if ~ischar(param), error(['Wrong option format : ',param]), end
  switch lower(param)
   case 'big_endian'
    header.BINTYPE='ieee-be';
   case 'cray_32bit_ieee'
    header.BINTYPE='cray';
   case 'little_endian'
    header.BINTYPE='ieee-le';
   case 'binprecision'
    % Strange syntax to eliminate digits in BINPRECISION
    param=words{2}(find(isnan(str2double(cellstr(upper(words{2})')))));
    if any(strmatch(param,...
		    {'uchar','schar','int','uint','float','single','double',...
		     'real*','integer*','bit','ubit','char','short','ushort', ...
		     'long','ulong'}))
      header.BINPRECISION=words{2};
    end
   case 'xrev'
    header.XDEF.rev=1;
   case 'yrev'
    header.YDEF.rev=1;
   case 'zrev'
    header.ZDEF.rev=1;
   case 'sequential' 
    % Structure of the binary file: ([4 bit][XYHEADER bit][XDEF.num
    % x YDEF.num x BINPRECISION bit][4 bit]) x NVAR
    header.SEQ=1;
   otherwise
    fprintf('Option %s not yet supported.\n',param);
  end
  end % for param=words
  %
% $$$   Matlab     C/Fortran       Description  
% $$$   'uchar'   'unsigned char'  unsigned character,  8 bits.
% $$$   'schar'   'signed char'    signed character,  8 bits.
% $$$   'int8'    'integer*1'      integer, 8 bits.
% $$$   'int16'   'integer*2'      integer, 16 bits.
% $$$   'int32'   'integer*4'      integer, 32 bits.
% $$$   'int64'   'integer*8'      integer, 64 bits.
% $$$   'uint8'   'integer*1'      unsigned integer, 8 bits.
% $$$   'uint16'  'integer*2'      unsigned integer, 16 bits.
% $$$   'uint32'  'integer*4'      unsigned integer, 32 bits.
% $$$   'uint64'  'integer*8'      unsigned integer, 64 bits.
% $$$   'single'  'real*4'         floating point, 32 bits.
% $$$   'float32' 'real*4'         floating point, 32 bits.
% $$$   'double'  'real*8'         floating point, 64 bits.
% $$$   'float64' 'real*8'         floating point, 64 bits.

 case 'XDEF'                   % Description of the X-axis (longitude usually)
  % Checking the number of x-grid coordinates:
  if isreal(str2num(words{1}))
    words{1}=str2num(words{1});
  elseif str2num(words{1})>1
  else
    error(['Wrong number of x-grid arguments : ', ...
					num2str(words{1})])
  end
  
  switch upper(words{2})
   case 'LINEAR'
    vec(1)=str2num(words{3});
    vec(2)=str2num(words{4});
    vec2=vec(1) + vec(2) * [0:(words{1}-1)];
    words{3}=vec2;				% KS, 24.11.2003: coord vector in all cases. 
   case 'LEVELS'
% $$$                 try % all on the same line
% $$$                     for i=1:words{1}
% $$$                         vec(i)=str2num(words{i+2});
% $$$                     end
% $$$ 		    words{3}=vec;
% $$$                 catch % all levels written column-wise
% $$$                     for i=1:words{1}
% $$$                         % vec(i)=fscanf(fid_ctl,'%i',1);
% $$$                         vec(i)=str2num(fgetl(fid_ctl));
% $$$                     end
% $$$ 		    words{3}=vec;
% $$$                 end
%   vec=str2num([words{3:end}]');
%   vec=str2num(cell2mat({words{3:end}}'))';
    vec=str2num(strvcat(words{3:end}));
    
    while length(vec) < words{1}
      point=ftell(fid_ctl);
      read_line=str2num(fgetl(fid_ctl));
      if isempty(read_line)
	fseek(fid_ctl,point,'bof');
	break
      else
	vec=cat(2,vec,read_line);
      end
    end
    if length(vec)==words{1}
      words{3}=vec;
    else
      error(['Unsuitable number of X-levels : ',num2str(length(vec))])
    end
   otherwise
    error(['Unsuitable x-mapping method : ',words{2}])
  end
  
  %	if header(1).XDEF.rev, words{3}=fliplr(words{3}); end
  [header(1).XDEF]=cell2struct({words{1},words{2},words{3},header(1).XDEF.rev},grid_fields,2);
  
  %
 case 'YDEF'                   % Description of the Y-axis (latitude usually)
   % Checking the number of y-grid coordinates:
   if isreal(str2num(words{1}))
     words{1}=str2num(words{1});
   elseif str2num(words{1})>1
   else
     error(['Wrong number of y-grid arguments : ', ...
	    num2str(words{1})])
   end
   
   switch upper(words{2})
    case 'LINEAR'
     vec(1)=str2num(words{3});
     vec(2)=str2num(words{4});
     vec2=vec(1) + vec(2) * [0:(words{1}-1)];
     words{3}=vec2;
    case 'LEVELS'
% $$$                 try % all on the same line
% $$$                     for i=1:words{1}
% $$$                         vec(i)=str2num(words{i+2});
% $$$                     end
% $$$ 		    words{3}=vec;
% $$$                 catch % all levels written column-wise
% $$$                     for i=1:words{1}
% $$$                         % vec(i)=fscanf(fid_ctl,'%i',1);
% $$$                         vec(i)=str2num(fgetl(fid_ctl));
% $$$                     end
% $$$ 		    words{3}=vec;
% $$$                 end
%    vec=str2num([words{3:end}]');
%    vec=str2num(cell2mat({words{3:end}}'))';
     vec=str2num(strvcat(words{3:end}));
     while length(vec) < words{1}
       point=ftell(fid_ctl);
       read_line=str2num(fgetl(fid_ctl));
       if isempty(read_line)
	 fseek(fid_ctl,point,'bof');
	 break
       else
	 vec=cat(2,vec,read_line);
       end
     end
     if length(vec)==words{1}
       words{3}=vec;
     else
       error(['Unsuitable number of Y-levels : ',num2str(length(vec))])
     end
    otherwise
     error(['Unsuitable y-mapping method : ',words{2}])
   end
   
%	if header.YDEF.rev, words{3}=fliplr(words{3}); end
   [header(1).YDEF]=cell2struct({words{1},words{2},words{3},header(1).YDEF.rev},grid_fields,2);
   %
 case 'ZDEF'                   % Description of the Z-axis
    % Checking the number of z-grid coordinates:
    if isreal(str2num(words{1}))
      words{1}=str2num(words{1});
    elseif str2num(words{1})>1
    else
      error(['Wrong number of z-grid arguments : ', ...
	     num2str(words{1})])
    end
    
    switch upper(words{2})
     case 'LINEAR'
      vec(1)=str2num(words{3});
      vec(2)=str2num(words{4});
      vec2=vec(1) + vec(2) * [0:(words{1}-1)];
      words{3}=vec2;
     case 'LEVELS'
% $$$                 try % all on the same line
% $$$                     for i=1:str2num(words{1})
% $$$                         vec(i)=str2num(words{i+2});
% $$$                     end
% $$$ 		    words{3}=vec;
% $$$                 catch % all levels written column-wise
% $$$                     for i=1:words{1}
% $$$                         % vec(i)=fscanf(fid_ctl,'%i',1);
% $$$                         vec(i)=str2num(fgetl(fid_ctl));
% $$$                     end
% $$$ 		    words{3}=vec;
% $$$                 end
%     vec=str2num([words{3:end}]');
%     vec=str2num(cell2mat({words{3:end}}'))';
      vec=str2num(strvcat(words{3:end}));
      while length(vec) < words{1}
	point=ftell(fid_ctl);
	read_line=str2num(fgetl(fid_ctl));
	if isempty(read_line)
	  fseek(fid_ctl,point,'bof');
	  break
	else
	  vec=cat(2,vec,read_line);
	end
      end
      if length(vec)==words{1}
	words{3}=vec;
      else
	error(['Unsuitable number of Z-levels : ',num2str(length(vec))])
      end
     otherwise
      error(['Unsuitable z-mapping method : ',words{2}])
    end
    
    %	if header.ZDEF.rev, words{3}=fliplr(words{3}); end
    [header(1).ZDEF]=cell2struct({words{1},words{2},words{3},header(1).ZDEF.rev},grid_fields,2);
    %
 case 'TDEF'                   % Description of the T-axis
  % Checking the number of t-grid coordinates:
  if isreal(str2num(words{1}))
    words{1}=str2num(words{1});
  elseif str2num(words{1})>1
  else
    error(['Wrong number of t-scale argument : ', ...
	   num2str(words{1})])
  end
  
  if any(upper(words{2})~='LINEAR')
    error(['Unsuitable t-mapping method : ',words{2}])
  end
  
  param=words{3};
  if (param(3)~=':' | param(6)~='Z' | ...
      ~isreal(str2num(param([1:2 4:5 7:8 12:length(param)]))))
    error(['Unsuitable date format : ',param])
  else
    vec(1)=str2num(param(1:2));          % hour
    vec(2)=str2num(param(4:5));          % min
    vec(3)=str2num(param(7:8));          % day
    switch lower(param(9:11))            % month
     case 'jan'
      vec(4)=1;
     case 'feb'
      vec(4)=2;
     case 'mar'
      vec(4)=3;
     case 'apr'
      vec(4)=4;
     case 'may'
      vec(4)=5;
     case 'jun'
      vec(4)=6;
     case 'jul'
      vec(4)=7;
     case 'aug'
      vec(4)=8;
     case 'sep'
      vec(4)=9;
     case 'oct'
      vec(4)=10;
     case 'nov'
      vec(4)=11;
     case 'dec'
      vec(4)=12;
     otherwise
      error(['Wrong month format : ',param(9:11)])
    end
    
    vec(5)=str2num(param(12:length(param)));       % year
    if vec(5)<10
      vec(5)=vec(5)+2000;
    elseif vec(5)<100
      vec(5)=vec(5)+1900;
    end
    
    % The time-axis is written in the matlab-time format
    % (cf. datestr, datevec...):
    init_time=datenum(vec(5),vec(4),vec(3),vec(1),vec(2),0);
    
    param=words{4};
    if isreal(str2num(param(1:end-2)))
      time_increment=str2num(param(1:end-2));
      param(1:end-2)=[];
    else
      error(['Wrong time increment argument : ',param])
    end
    
    switch lower(param)
     case 'mn'
      time_increment=time_increment*datenum(0,0,0,0,1,0);
     case 'hr'
      time_increment=time_increment*datenum(0,0,0,1,0,0);
     case 'dy'       % NB: datenum(0,0,1,0,0,0) = 1.
      time_increment=time_increment;
     case 'mo'       % standardised month
      time_increment=time_increment*365.25/12;
     case 'yr'       % standardised year
      time_increment=time_increment*365.25;
     otherwise
      error(['Wrong time increment argument : ',param])
    end
    
    % Writing the final time axis:
    clear vec
    vec(1)=init_time;
    vec(2)=time_increment;
    
    [header(1).TDEF]=cell2struct({words{1},words{2},vec,0},grid_fields,2);
  end
  %
 case 'VARS'                   % Number and size of variables
  if isreal(str2num(words{1}))
    n_var = str2num(words{1});
  else
    error(['Wrong variable number argument : ',words{1}])
  end
  
  % Reading the variables : 
  
  var_format={'id','name','levs','units','descr'};
  varl={};
  
  for i=1:n_var
    line_var=fgetl(fid_ctl);
    n_blank=length(line_var);
    line_var=strrep(line_var,'  ',' ');
    while length(line_var) < n_blank
      n_blank=length(line_var);
      line_var=strrep(line_var,'  ',' ');
    end
    while isspace(line_var(1)), line_var(1)=[]; end
    var_loc={i,'',NaN,'',''};
    var_hole=min(find(isspace(line_var)));
    var_loc{2}=line_var(1:(var_hole-1));
    line_var(1:var_hole)=[];
    
    var_hole=min(find(isspace(line_var)));
    var_loc{3}=str2num(line_var(1:(var_hole-1)));
  % cf GrADS doc:  If levs is 0, the variable does not correspond
  % to any vertical level
    var_loc{3}=max([var_loc{3},1]);
    line_var(1:var_hole)=[];
    
    var_hole=min(find(isspace(line_var)));
    var_loc{4}=line_var(1:(var_hole-1));
    line_var(1:var_hole)=[];
    
    var_loc{5}=line_var;
    
    varl=cat(1,varl,var_loc);
  end
  
  vars=cell2struct(varl,var_format,2);
  
  if ~l_quiet
    disp(['Is it the end ? ',fgets(fid_ctl)]);
  else
    endvars=deblank(fgets(fid_ctl));
    if ~strcmpi((endvars),'ENDVARS')
      error(['Wrong end of file : ',endvars])
    end
  end
  
  header(1).VARS=vars;
  assignin('caller','vars',vars);
  %
 case 'FILEHEADER'              %  n-byte header of binary data, not to be read
  [header.FILEHEADER]=str2num(words{1});
  %
 case 'THEADER'                 % n-byte header for each T-block, not to be read
  [header.THEADER]=str2num(words{1});
  %
 case 'XYHEADER'                % n-byte header for each XY-block, not to be read
  [header.XYHEADER]=str2num(words{1});
  %
 otherwise
  error(['Unknown entry : ',entry])
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function data=read_data(header,var_name)
% data=read_data(header,var_name) is a function, usually called by
% read_grads.m to use the information contained in the header file
% (.ctl) for reading a binary GrADS file.
% If var_name is 'all', all variables are read and sent to the base-
% workspace.  
% Kristof Sturm, 29.10.02

global l_quiet

vars=header.VARS;
nvar=header.NVAR;
var_size=header.VARSIZE{:};

if nargin == 1 | strcmp(lower(var_name),'all')           % All variables loaded into workspace
  data_list={};
  % initialising the data matrices : 
  var_count=zeros(nvar,1);
  for ivar=1:nvar
    eval([vars(ivar).name,'=NaN*ones(',int2str(header.XDEF.num),',',...
	  int2str(header.YDEF.num),',',...
	  int2str(vars(ivar).levs),',',...
	  int2str(header.TDEF.num),');']);
    fprintf('Size of %s : [%s].\n            %s[X   Y   Z    T]\n',...
	    vars(ivar).name,int2str(size(eval(vars(ivar).name))),...
	    char(32*ones(1,length(vars(ivar).name))));
  end
  
  method = 'loop';  % mainly for debugging... 
    
  switch method
   case 'loop'
    frewind(header.FID{2});
    % Implementing the sequential option:
    if isfield(header,'SEQ') && header.SEQ
      fseek(header.FID{2},4,'bof');
    end

    if header.FILEHEADER
      fseek(header.FID{2},header.FILEHEADER,'bof');
% $$$ if isfield(header,'SEQ') && header.SEQ
% $$$ 	fseek(header.FID{2},8,'cof');
% $$$ end
    end
    
    for l=1:header.TDEF.num
      if header.THEADER
	fseek(header.FID{2},header.THEADER,'cof');
% $$$ 	if isfield(header,'SEQ') && header.SEQ
% $$$ 	  fseek(header.FID{2},8,'cof');
% $$$ 	end
      end
      for ivar=1:nvar
	data=eval(vars(ivar).name);
	count0=var_count(ivar);
	for k=1:vars(ivar).levs
	  if header.XYHEADER
	    fseek(header.FID{2},header.XYHEADER,'cof');
	  end
	  [data(:,:,k,l) count1]=fread(header.FID{2},[header.XDEF.num header.YDEF.num],header.BINPRECISION);
	  count0=count0+count1;
	  if isfield(header,'SEQ') && header.SEQ
	    fseek(header.FID{2},8,'cof');
	  end
	end                                   % end k-loop
	data(data==header.UNDEF)=NaN;   % replacing the
                                        % missing/undefined values
                                        % by NaN (not-a-number)
					
%	data(data==header.UNDEF)=0;   % replacing the
                                      % missing/undefined values by
                                      % NaN (not-a-number)
%	data=sparse(data);			      
	eval([vars(ivar).name,'=data;']);
	var_count(ivar)=var_count(ivar)+count0;
	% bytes(ivar)=ftell(header.FID{2});
	clear data
      end                                     % end ivar-loop
    end                                       % end l-loop
    
    % Send the relevent variables into the base workspace:
    %	assignin('base','var_count',var_count);
    %       assignin('base','bytes',bytes);
    for ivar=1:nvar
      data=eval(vars(ivar).name);
      if header.XDEF.rev, data=flipdim(data,1); end
      if header.YDEF.rev, data=flipdim(data,2); end
      if header.ZDEF.rev, data=flipdim(data,3); end
      assignin('base',vars(ivar).name,data);
    end
    %                                             % end 'loop'
   otherwise
    for ivar=1:nvar
      data=read_var(header,vars(ivar).name);
      assignin('base',vars(ivar).name,data);
      data_list=cat(1,data_list,{data});
    end
    data=[];
    assignin('caller','data_list',data_list);
  end
else                                          % Individual var. reading
  switch var_name
   case {vars.name}
    fprintf('Variable %s extracted from %s. \n',var_name, ...
	    header.DATANAME);
    data=read_var(header,var_name);
   otherwise
    error(['Variable ',var_name,' not available in ', ...
	   header.DATANAME]);
  end
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function data=read_var(header,ivar,t_limits,z_limits,y_limits,x_limits)
% data=read_varseq(header,ivar) reads in 'ivar' from
% 'header.DATANAME' and return it as a 4-D matlab matrix. 
% 'ivar' can be the variable''s short name or its number id.

global l_quiet

vars=header.VARS;
nvar=header.NVAR;
var_size=header.VARSIZE{:};

% different behaviour of the f* functions according to the chosen data precision :
switch lower(header.BINPRECISION)
 case {'uchar','schar','int8','uint8'}
  byte_length=1;
 case {'int16','uint16'}
  byte_length=2;  
 case {'float32','single','int32','uint32'}
  byte_length=4;
 case {'float64','double','int64','uint64'}
  byte_length=8;
 otherwise
  byte_length=1;
end

if isempty(ivar)
  if ~l_quiet
    disp(['Header for ',header.FILENAME,' read.'])
  end
  data=[];
  return
end

if ischar(ivar)
  var_name=ivar;
  ivar=strmatch(ivar,{vars.name},'exact');
  if isempty(ivar)
    if ~l_quiet
      disp(['The variable ',var_name,' cannot be found in ',header.DATANAME])
    end
    data=[];
    return
  end
  clear var_name
end

if ivar==1
  byte_ini=0;
else
  byte_ini = sum(prod(var_size(1:(ivar-1),1:3),2),1) ;
end

if isfield(header,'SEQ') && header.SEQ
  byte_ini=byte_ini+(sum(var_size(1:ivar-1,3))*8+4)/byte_length;
end

if header.FILEHEADER
  byte_ini = byte_ini + header.FILEHEADER/byte_length;
% $$$   if isfield(header,'SEQ') && header.SEQ
% $$$     byte_ini=byte_ini+8/byte_length;
% $$$   end
end

if header.THEADER
  byte_ini = byte_ini + header.THEADER/byte_length;
% $$$   if isfield(header,'SEQ') && header.SEQ
% $$$     byte_ini=byte_ini+8/byte_length;
% $$$   end
end

if header.XYHEADER
  byte_ini=byte_ini+(sum(var_size(1:ivar-1,3))+1)*header.XYHEADER/byte_length;
% $$$   if isfield(header,'SEQ') && header.SEQ
% $$$     byte_ini=byte_ini+(sum(var_size(1:ivar-1,3))+1)*8/byte_length;
% $$$   end
end

block_length = sum(prod(var_size(:,1:3),2),1);

if isfield(header,'SEQ') && header.SEQ
 block_length=block_length+sum(var_size(:,3))*8/byte_length;
end

if header.XYHEADER
  block_length=block_length+sum(var_size(:,3))*header.XYHEADER/byte_length;
end

if header.THEADER
  block_length=block_length+header.THEADER/byte_length;
end

slice_length = header.XDEF.num*header.YDEF.num+header.XYHEADER/byte_length;

if isfield(header,'SEQ') && header.SEQ
  slice_length = slice_length + 8/byte_length ;
end

var_length = prod([header.XDEF.num header.YDEF.num diff(z_limits)+1]);

if header.XYHEADER
  var_length = var_length + (diff(z_limits)+1)*header.XYHEADER/byte_length;
end

if isfield(header,'SEQ') && header.SEQ
  var_length=var_length+(diff(z_limits)+1)*8/byte_length;
end

% disp(byte_ini)
% Selecting the starting time slice :
byte_ini=byte_ini + (t_limits(1)-1)*block_length + (z_limits(1)-1)*slice_length ;

err_stat = fseek(header.FID{2},byte_ini*byte_length,'bof');
if err_stat == -1, ferror(header.FID{2}), end

% data=NaN(diff(x_limits)+1,diff(y_limits)+1,diff(z_limits)+1,diff(t_limits)+1);
data=NaN*ones(diff(x_limits)+1,diff(y_limits)+1,diff(z_limits)+1,diff(t_limits)+1);

%   size(data)
count_byte = 0;
count_byte2 = 0;
for l=1:(t_limits(2)-t_limits(1)+1)
  file_ind = ftell(header.FID{2});
  for k=1:(z_limits(2)-z_limits(1)+1)
    if all([x_limits y_limits]==[1 header.XDEF.num 1 header.YDEF.num])
    try
      [data(:,:,k,l),n]=fread(header.FID{2},[header.XDEF.num header.YDEF.num],header.BINPRECISION);
      count_byte=count_byte+n;
    catch
      warning(['Data read-in interrupted at l=',int2str(l),' and k=',int2str(k)])
      break
    end
    else
    % Advance to the j-th row:
    fseek(header.FID{2},(y_limits(1)-1)*header.XDEF.num*byte_length,'cof');
    for j=1:(diff(y_limits)+1)
      fseek(header.FID{2},(x_limits(1)-1)*byte_length,'cof');
      [data(:,j,k,l),n]=fread(header.FID{2},diff(x_limits)+1,header.BINPRECISION);
      fseek(header.FID{2},(header.XDEF.num-x_limits(2))*byte_length,'cof');
    end
    fseek(header.FID{2},(header.YDEF.num-y_limits(2))*header.XDEF.num*byte_length,'cof');
    end
    if isfield(header,'SEQ') && header.SEQ
      fseek(header.FID{2},8,'cof');
    end
    if header.XYHEADER
      fseek(header.FID{2},header.XYHEADER,'cof');
    end
  end
  count_byte2=count_byte2+ftell(header.FID{2})-file_ind;
  if l < header.TDEF.num
    err_stat=fseek(header.FID{2},(block_length-var_length)*byte_length,'cof');
    if err_stat == -1, ferror(header.FID{2}), end
  end
end

% disp([byte_ini block_length slice_length var_length file_ind/byte_length ftell(header.FID{2})/byte_length])

data(find(data==header.UNDEF))=NaN;   % replacing the missing/undefined values by NaN (not-a-number)

if header.XDEF.rev, data=flipdim(data,1); end
if header.YDEF.rev, data=flipdim(data,2); end
if header.ZDEF.rev, data=flipdim(data,3); end

%if count_byte ~= count_byte2/byte_length
%  warning(['Number of elements read : ',num2str(count_byte),...
%	   ' .NEQ. number of bytes advanced in ',header.DATANAME,': ',num2str(count_byte2/byte_length)])
%end

%fprintf('%i bytes were read in %s .\n size(%s) = [%s], i.e. %i elements.\n',...
%        count_byte2,header.DATANAME,vars(ivar).name,int2str(size(data)),count_byte);
%	count_byte2,header.DATANAME,vars(ivar).name,int2str(size(data)),prod(size(data)));

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function data=read_station(header)
% This function uses the information read from the GrADS .ctl file
% to read STATION data into the matlab workspace. 
% No reference to the .map file is currently made.
% cf. http://grads.iges.org/grads/gradoc/aboutstationdata.html
% Kristof Sturm, 30.X.02

global l_quiet

fid_bin = header.FID{2};
fseek(fid_bin,0,'eof');
eof=ftell(fid_bin);
frewind(fid_bin);
file_end=0;
istat=1;

data_format={'id','name','lat','lon','var'};
data_tot={};
% Reading the header :

while 1
  
  data_loc={0,'',0,0,[]};
  
  boh=ftell(fid_bin);
  
  stid=fscanf(fid_bin,'%8c',1);
  lat=fread(fid_bin,1,'float32');
  lon=fread(fid_bin,1,'float32');
  tim=fread(fid_bin,1,'float32');
  nlev=fread(fid_bin,1,'int32');
  nflag=fread(fid_bin,1,'int32');
  
  eoh=ftell(fid_bin);
  length_h=eoh-boh;
  
  var=NaN(header.NVAR,header.TDEF.num);
  
  % Reading all variables, skipping the headers :
  for t=1:header.TDEF.num
    
    var(:,t)=fread(fid_bin,header.NVAR,'float32');
    
    if ftell(fid_bin) < (eof-2*length_h)
      file_err=fseek(fid_bin,2*length_h,'cof');
      if file_err==-1, ferror(fid_bin), end
    else
      fprintf('EOF reached for %s.\n\n',header.DATANAME);
      file_end=1;
      break
    end
    var(find(var==header.UNDEF))=NaN;
  end
  
  if file_end, break, end
  
  % Rewinding for reading the first of the next headers :
  file_err=fseek(fid_bin,-length_h,'cof');
  if file_err==-1, ferror(fid_bin), end
  
  % saving all relevant informations into the local cell :
  [data_loc]={istat,deblank(lower(stid)),lat,lon,var};
  data_tot=cat(1,data_tot,data_loc);
  istat=istat+1;
end

data=cell2struct(data_tot,data_format,2);

return
    
