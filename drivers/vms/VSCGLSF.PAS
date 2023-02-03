MODULE vsta$cgl_segfun;
{-----------------------------------------------------------------------------
!
!  SEGFUN.PRG - CGL segment manager for PRO GIDIS
!
-----------------------------------------------------------------------------}

%include 'VSTA$LIBRARY:VSCGLDEF'

{table of contents}

[global] procedure G$do(var command : G$instr_type); forward;

{external references}

procedure G$iron(var command : G$instr_type); external;

procedure G$do;
  {(var command : G$instr_type)}

begin
  G$iron(command)
end;



END.
