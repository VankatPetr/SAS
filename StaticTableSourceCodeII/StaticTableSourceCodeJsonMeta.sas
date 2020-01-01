/*--------------------------------------------------------*/
/*--Generate json file based on existing metadata table --*/
/*--------------------------------------------------------*/

%macro meta_json(metapath, metatable);
	%let libpath=&metapath.;
	%let metatable=&metatable.;
	libname lib "&libpath.";
	
	proc json out="&libpath./&metatable..json" pretty;
		export lib.&metatable.;
	run;
%mend meta_json;

/*example of the meta_json macro */
*%meta_json(/home/petrvankat0/Metadata,class);

/*--------------------------------------------------------*/
/*--Read json                                           --*/
/*--------------------------------------------------------*/

%macro meta_json_read(metapath, metatable);
	%let libpath=&metapath.;
	%let metatable=&metatable.;
	
	filename in "&libpath./&metatable..json";
	libname in json;
	
	proc sql noprint;
		select memname
		into :metajson
		from 
			dictionary.tables
		where 
			libname = 'IN' and memname like 'SASTABLE%' 
		;
	quit;
	
	proc print data=in.&metajson(drop=ordinal_root 
									   ordinal_&metajson ) 
				     noobs;
	run;
%mend meta_json_read;


/*example of the meta_json_read macro */
*%meta_json_read(/home/petrvankat0/Metadata,class);







