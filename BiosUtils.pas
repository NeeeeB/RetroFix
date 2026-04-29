unit BiosUtils;

interface

uses
   Types;

function biosStatusToStr( const aStatus: TBiosStatus ): string;

implementation

uses
   Constantes;

function biosStatusToStr( const aStatus: TBiosStatus ): string;
begin
   case aStatus of
      bsOK: Result:= rstBiosOK;
      bsPresentNoHash: Result:= rstBiosPresentNoHash;
      bsMD5Mismatch: Result:= rstBiosMD5Mismatch;
      bsMissing: Result:= rstBiosMissing;
   else
      Result:= '?';
   end;
end;

end.
