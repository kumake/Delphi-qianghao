program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  qianghao in 'qianghao.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '������Ʊ����V2.1';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
