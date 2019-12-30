
/*-----------------------------------------------------------------------------*/
/*--Prepare macro for generating proc sql create statement                   --*/
/*-----------------------------------------------------------------------------*/

%macro get_ddl(ds=,outfile=);
   filename tmp temp;
   proc printto log=tmp;quit;
   proc sql; describe table &ds;
   proc printto log=log;quit;
   data _null_;
      infile tmp;
      file &outfile;
      input;
      if _infile_=:'NOTE: SQL table ' then start+1;
      else if _infile_=:'NOTE: PROCEDURE SQL used' then stop;
      else if index(_infile_,'            The SAS System       ') then delete;
      else if start=1 then put _infile_;
      putlog _infile_;
   run;
   filename tmp;
%mend;

/*-----------------------------------------------------------------------------*/
/*--Prepare macro for generating metadata source code                        --*/
/*-----------------------------------------------------------------------------*/
%macro DS2SourceCode(metapath, metatable, TestScript=Yes);
	/*Define output library - the src code will recreate the meata table in 
	this library*/
	%if &TestScript=YES %then %do;
		%let workpath=%sysfunc(pathname(work));
		libname lib "&workpath.";
		%end;
	%else %do;
		libname lib "&metapath.";
		%end;
		
	/*Define metadata library*/
	libname metalib "&metapath";
	
	/*Copy the meta table int the work library*/
	proc copy in=metalib out=work;
		select &metatable;
	run;
	
	/*Create proc sql create table statement*/
	%get_ddl(ds=lib.&metatable., outfile="&metapath./&metatable._create.sas");
	
	/*Create proc sql insert statement*/
	data _null_;
		file "&metapath./&metatable._data.sas" dlm=',';
		set metalib.&metatable.;
		format _character_ $quote200.;
		put "Insert into lib.&metatable. values(" (_all_) (~) ');';
	run;
	
	/*Create source code which can replicate the meta table in the work library*/
	x muser=$(stat -c '%U' &metapath./&metatable..sas7bdat);
	x mgroup=$(stat -c '%G' &metapath./&metatable..sas7bdat);
	x echo "libname lib '%sysfunc(pathname(lib))';" > &metapath./&metatable..sas;
	x echo "proc sql noprint;" >> &metapath./&metatable..sas;
	x cat &metapath./&metatable._create.sas >> &metapath./&metatable..sas;
	x cat &metapath./&metatable._data.sas >> &metapath./&metatable..sas;
	x echo "quit;" >> &metapath./&metatable..sas;
	x chown ${muser}:${mgroup} &metapath./&metatable..sas;
	
	/*Remove unnecesary files*/
	x rm &metapath./&metatable._create.sas;
	x rm &metapath./&metatable._data.sas;
	
	/*Remove temp tables*/
	proc delete data = work.&metatable.;
	run;
%mend DS2SourceCode;

/*-----------------------------------------------------------------------------*/
/*--Test the metadata source code and output fina version                    --*/
/*-----------------------------------------------------------------------------*/
%macro meta(metapath, metatable);
	/*Create src script using the work library as output destination for the meta table*/
	%DS2SourceCode(&metapath, &metatable, TestScript=YES);
	
	/*Replicate the meta table in the work library using the newly created src script*/
	options nosource nonotes;
	%include "&metapath./&metatable..sas";
	options source notes;
	
	/*Compare the meta table from the metadata library and the newly created meta table
	from the work library*/
	proc compare base=metalib.&metatable.
				 compare=work.&metatable.;
	run;
	
	/*Generate final source code*/
	%let metarc=&sysinfo;
	%put RC: &metarc;
	%if &metarc eq 0 %then %do;
		%DS2SourceCode(&metapath, &metatable); /*i.e. TestScript=NO*/
		%end;
	%else %do;
		%put Source code does not generate the same sas dataset;
		x rm &metapath./&metatable..sas;
		%end;
		
%mend meta;

/*run macro example*/
*%meta(Home/usr/metadata, holiday);


		
	
	




