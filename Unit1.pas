unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP,qianghao,quhao, OleCtrls, SHDocVw, ExtCtrls,PerlRegEx,
  sSkinManager,DateUtils, ComCtrls,shellapi, acProgressBar, sGroupBox;

type
  TForm1 = class(TForm)
    Button1: TButton;
    pindaocom: TComboBox;
    Label5: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    sSkinManager1: TsSkinManager;
    Label_yuantime: TLabel;
    Timer2: TTimer;
    Label8: TLabel;
    Label6: TLabel;
    Label_status: TLabel;
    Label7: TLabel;
    Label11: TLabel;
    ProgressBar_status: TsProgressBar;
    sGroupBox1: TsGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    ComboBox1: TComboBox;
    Edit3: TEdit;
    Edit2: TEdit;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Label11Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function GetNumber(id:string;name:string;tele:string;typestr:string):string;  //������½
  function Getrandomspan(tempint:integer):string;
  function CheckNumber(id:string):string;
  function MYHTTPEncode(const AStr: String): String;  //����ո��+����
  function Writetotxt(contenttxt:string):boolean;
  function PostPiao(id:string;name:string;tele:string;typestr:string;pindao:string;rd:string;pinfo:string):string;  //�ύƱ
  function GetInfo(htmltxt:string):string;  //��ȡƱ����Ϣ
  
  var
  Form1: TForm1;
  M_gh,M_xm,M_tel,M_lx,P_info:string;
  MYQH:array[0..100] of QH;
  MYQUH:array[0..100] of QUH;
  flag:boolean=false;
  quhaoflag:boolean=false;
  radspanint:integer=0;
  FLock:TRTLCriticalSection; //�����ٽ�����
  pindaoint:integer;
  TimeCha:integer;
  TimeQiangPiao,Timeyanshou:integer;  //��Ʊʱ�䣨13:29:50��������ʱ�� ��13:30:05��
  GLOBAL_FLAG:byte=0;//ȫ��״̬ 0���еȴ���1׼����Ʊ��2��Ʊ�׶Σ�3���ս׶Σ�4���ս��� ��5��ȡ����
  todaydate:string;
const
  SPANCHARS:array[0..9] of char =(chr(9),chr(10),chr(11),chr(12),chr(13),chr(28),chr(29),chr(30),chr(31),chr(32));
  //SPANCHARS:array[0..9] of char =('0','1','2','3','4','5','6','7','8','9');

implementation


{$R *.dfm}
//ת������
function MyStrToDateTime(sTime:String):TDateTime;
var
  settings: TFormatSettings;
begin
  GetLocaleFormatSettings(GetUserDefaultLCID, settings);
  settings.DateSeparator := '-';
  settings.TimeSeparator := ':';
  settings.ShortDateFormat := 'yyyy-m-d';
  settings.ShortTimeFormat := 'hh:nn:ss';
  result:= strToDateTime(sTime,settings);
end;


function MYHTTPEncode(const AStr: String): String;  //����ո��+����
// The NoConversion set contains characters as specificed in RFC 1738 and
// should not be modified unless the standard changes.
const
  NoConversion = ['A'..'Z','a'..'z','*','@','.','_','-',
                  '0'..'9','$','!','''','(',')'];
var
  Sp, Rp: PChar;
begin
  SetLength(Result, Length(AStr) * 3);
  Sp := PChar(AStr);
  Rp := PChar(Result);
  while Sp^ <> #0 do
  begin
    if Sp^ in NoConversion then
      Rp^ := Sp^
    else
      begin
        FormatBuf(Rp^, 3, '%%%.2x', 6, [Ord(Sp^)]);
        Inc(Rp,2);
      end;
    Inc(Rp);
    Inc(Sp);
  end;
  SetLength(Result, Rp - PChar(Result));
end;


function Writetotxt(contenttxt:string):boolean;
var
FPath: string;
pMyFile: textFile;
begin
    FPath:=formatDateTime('yyyymmdd',now)+'.txt';
    try
        AssignFile(pMyFile,FPath);
        if FileExists(FPath)=false then
            ReWrite(pMyFile)
        else
            Append(pMyFile);
        WriteLn(pMyFile,contenttxt);
    finally
        CloseFile(pMyFile);
    end;
    result:=true;
end;



function GetNumber(id:string;name:string;tele:string;typestr:string):string;  //������½
var
Params: TStrings;
Response: TStringStream;
TempHttp: TIdHTTP;
begin
  Response := TStringStream.Create('');
  Params:=TStringList.Create;
  TempHttp:= TIdHTTP.Create(nil);
 // TempHttp.HandleRedirects:=true;
  TempHttp.ReadTimeout:=1000;

   try
    Params.Add('id='+AnsiToUtf8(id));
    Params.Add('name='+AnsiToUtf8(name));
    Params.Add('tele='+AnsiToUtf8(tele));
    Params.Add('type='+AnsiToUtf8(typestr));


    TempHttp.Request.Referer:='http://172.16.102.207:81/quhao/';
    TempHttp.post('http://172.16.102.207:81/quhao/getNumber.jsp',Params,Response);
   except
   Result:='';
    Response.Free;
    Params.Free;
    TempHttp.Free;
    exit;
   end;

   Result:=utf8toansi(Response.DataString);

    Params.Free;
    Response.Free;
    TempHttp.Free;

end;


function CheckNumber(id:string):string;
var
Response: TStringStream;
TempHttp: TIdHTTP;
begin
  Response := TStringStream.Create('');
  TempHttp:= TIdHTTP.Create(nil);
  TempHttp.HandleRedirects:=true;
  TempHttp.ReadTimeout:=3000;
   Result:='';
   try
    TempHttp.get('http://172.16.102.207:81/quhao/history.jsp?id='+id,Response);
   except
   Result:='';
    Response.Free;
    TempHttp.Free;
    exit;
   end;

   result:=utf8toansi(Response.DataString);

    Response.Free;
    TempHttp.Free;

end;

function Getrandomspan(tempint:integer):string;
var
wei,yu:integer;
tempstr:string;
begin
   {EnterCriticalSection(FLock); //�����ٽ�����
        tempint:= radspanint;
        radspanint:=radspanint+1;
        if (radspanint>99999) then
        radspanint:=0;
   LeaveCriticalSection(FLock); //�˳��ٽ����� }

   wei:= tempint;
   repeat
    yu:=wei mod  10 ;
    wei:=wei div  10;
    tempstr:= SPANCHARS[yu]+tempstr;
   until(wei=0);

   result:=tempstr ;
end;


function GetInfo(htmltxt:string):string;  //��ȡƱ����Ϣ
var
reg: TPerlRegEx;
tempstr:string;
retstr:string;
begin

    reg := TPerlRegEx.Create;
    reg.Options := [preCaseLess,preSingleLine];

    reg.Subject := htmltxt;
    reg.RegEx   := 'id\=\"user_number\"\>([0-9]+)\<\/td\>';
    if reg.MatchAgain  then
    tempstr:=reg.Groups[1]
    else
    begin
    tempstr:='';
    FreeAndNil(reg);
    exit;
    end;

    retstr:=retstr+tempstr;

    reg.RegEx   := '\>([0-9]+\-[0-9]+\-[0-9]+)\<';
    if reg.MatchAgain  then
    tempstr:=reg.Groups[1]
    else
    begin
    tempstr:='';
    FreeAndNil(reg);
    exit;
    end;

    retstr:=retstr+','+tempstr;

    reg.RegEx   := '\>([0-9]+\-[0-9]+\-[0-9]+\s[0-9]+\:[0-9]+\:[0-9]+)\<';
    if reg.MatchAgain  then
    tempstr:=reg.Groups[1]
    else
    begin
    tempstr:='';
    FreeAndNil(reg);
    exit;
    end;

    retstr:=retstr+','+tempstr;


    FreeAndNil(reg);

    result:=retstr;
end;

function PostPiao(id:string;name:string;tele:string;typestr:string;pindao:string;rd:string;pinfo:string):string;  //�ύƱ
var
Params: TStrings;
Response: TStringStream;
TempHttp: TIdHTTP;
begin
  Response := TStringStream.Create('');
  Params:=TStringList.Create;
  TempHttp:= TIdHTTP.Create(nil);
  TempHttp.ReadTimeout:=5000;

   try
    Params.Add('gh='+AnsiToUtf8(id));
    Params.Add('xm='+AnsiToUtf8(name));
    Params.Add('dh='+AnsiToUtf8(tele));
    Params.Add('lx='+AnsiToUtf8(typestr));
    Params.Add('pd='+AnsiToUtf8(pindao));
    Params.Add('rd='+AnsiToUtf8(rd));
    Params.Add('pinfo='+AnsiToUtf8(pinfo));

    TempHttp.post('http://nuistqp.duapp.com/in.php',Params,Response);
   except
    Result:='';
    Response.Free;
    Params.Free;
    TempHttp.Free;
    exit;
   end;

   Result:=utf8toansi(Response.DataString);

    Params.Free;
    Response.Free;
    TempHttp.Free;
end;


function GetTime():string;
var
reg: TPerlRegEx;
Response: TStringStream;
TempHttp: TIdHTTP;
tempstr:string;
begin
  Response := TStringStream.Create('');
  TempHttp:= TIdHTTP.Create(nil);
  TempHttp.HandleRedirects:=true;
  TempHttp.ReadTimeout:=1000;
   Result:='';
   try
    TempHttp.get('http://172.16.102.207:81/quhao/index.jsp',Response);
   except
   Result:='';
    Response.Free;
    TempHttp.Free;
    exit;
   end;

   tempstr:=utf8toansi(Response.DataString);

    Response.Free;
    TempHttp.Free;


    reg := TPerlRegEx.Create;
    reg.Options := [preCaseLess,preSingleLine];

    reg.Subject := tempstr;
    reg.RegEx   := '([0-9]+)��([0-9]+)��([0-9]+)��([0-9]+)ʱ([0-9]+)��([0-9]+)';
    if reg.MatchAgain  then
    tempstr:=reg.Groups[1]+'-'+reg.Groups[2]+'-'+reg.Groups[3]+' '+reg.Groups[4]+':'+reg.Groups[5]+':'+reg.Groups[6]
    else
    begin
    tempstr:='';
    FreeAndNil(reg);
    exit;
    end;

    FreeAndNil(reg);

    //MinutesBetween
    //tempstr:='2013-11-13 23:20:00';

    result:=tempstr;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
if button1.Caption='��ʼ' then
begin
   flag:=false;
   quhaoflag:=false;
    //Memo1.Text:= GetNumber(edit1.Text,edit2.Text,edit3.Text,ComboBox1.Text);
    //showmessage(edit1.Text+' '+edit2.Text+' '+edit3.Text+' '+ComboBox1.Text);
    M_gh:=edit1.Text;
    M_xm:=edit2.Text;
    M_tel:=edit3.Text;
    M_lx:=ComboBox1.Text;

    if  (M_gh='') or (M_xm='')or (M_tel='') then
    begin
    showmessage('���ţ��������绰��ȫ��');
    exit;
    end;

    //Ƶ��
    if (pindaocom.Text='') then
    begin
    showmessage('��ѡ��Ƶ���ţ��Ҳ��ܺͱ�����ͬ��');
    exit;
    end;
    pindaoint:=strtoint(pindaocom.Text);
    radspanint:=pindaoint*1000;
 {
    if ((DateTimeToUnix(now)+TimeCha)>(TimeQiangPiao+13)) then
    begin
        showmessage('�������Ʊ�Ѿ�������');
        exit;
    end;
 }
    GLOBAL_FLAG:=1;//����׼����Ʊ״̬
    button1.Caption:='����';
end
else
begin
     flag:=true;
     quhaoflag:=true;

    GLOBAL_FLAG:=0;//�������״̬
    button1.Caption:='��ʼ';

    Label_status.Caption:='����' ;
    ProgressBar_status.Position:=0;

end;




end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
i:integer;
begin
if button1.Caption='����' then
begin
     flag:=true;
     quhaoflag:=true;
      //�����߳�
      for i:=0 to high(MYQH) do
    begin
       if   Assigned(MYQH[i])   then
        begin
          MYQH[i].Terminate;
          MYQH[i].Resume;
          MYQH[i].WaitFor;
          MYQH[i].Free;
        end;
    end;

    for i:=0 to high(MYQUH) do
    begin
       if   Assigned(MYQUH[i])   then
        begin
          MYQUH[i].Terminate;
          MYQUH[i].Resume;
          MYQUH[i].WaitFor;
          MYQUH[i].Free;
        end;
    end;
   DeleteCriticalSection(FLock);//ɾ���ٽ�����
end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
i:integer;
tempstr:string;
DateTime1,DateTimeGuoQi: tDateTime;
begin

//ʱ�����
  tempstr:=GetTime();
  if tempstr='' then
  begin
    showmessage('��������!');
    Application.Terminate;
    exit;
  end;



  DateTime1 := MyStrToDateTime(tempstr);
  DateTimeGuoQi := MyStrToDateTime('2014-01-30 00:00:00');
  if (DateTime1> DateTimeGuoQi) then
  begin
    Application.Terminate;
    exit;
  end;

  TimeCha:=DateTimeToUnix(DateTime1)-DateTimeToUnix(now); //ʱ���

  todaydate:=formatDateTime('yyyy-mm-dd',DateTime1);

  TimeQiangPiao:=DateTimeToUnix(MyStrToDateTime(todaydate+' 13:29:45')); //��Ʊʱ��


{  if (DateTimeToUnix(DateTime1)>TimeQiangPiao) then
  begin
        showmessage('�������Ʊ�Ѿ�������');
        Application.Terminate;
        exit;
  end;
 }
  Timeyanshou:=DateTimeToUnix(MyStrToDateTime(todaydate+' 13:30:05'));  //����ʱ��


InitializeCriticalSection(FLock); //��ʼ���ٽ�����
for i:=0 to high(MYQH) do
MYQH[i]:=QH.Create(true);

for i:=0 to high(MYQUH) do
MYQUH[i]:=QUH.Create(true);

end;

procedure TForm1.Timer2Timer(Sender: TObject);
var
i:integer;
yuan_unix:integer;
begin
yuan_unix:=DateTimeToUnix(now)+TimeCha;
Label_yuantime.Caption:= formatDateTime('yyyy-mm-dd hh:nn:ss',UnixToDateTime(yuan_unix));

//-----------------------------------------------------
if  (GLOBAL_FLAG=1) then  //׼����Ʊ
begin
    if (yuan_unix>TimeQiangPiao) then
      begin
        //13:29:45���ѵ���������Ʊ
        GLOBAL_FLAG:=2;
         //������Ʊ����
          flag:=false;
          quhaoflag:=true;
         radspanint:=pindaoint*1000;
        for i:=0 to high(MYQH) do
        MYQH[i].Resume;
      end;

    Label_status.Caption:='�ȴ���Ʊ��ʱ��Ϊ13:29:45ʱ����~~~' ;
    ProgressBar_status.Position:=10;
end;
//-----------------------------------------------------

if  (GLOBAL_FLAG=2) then   //������Ʊ
begin
    if (yuan_unix>Timeyanshou) then
    begin
        //13:30:05���ѵ���׼������
        GLOBAL_FLAG:=3;
         //׼������
      end;
    if (ProgressBar_status.Position<30) then
    begin
    Label_status.Caption:='������Ʊ�������ĵȴ�����' ;
    ProgressBar_status.Position:=30;
    end
    else
    ProgressBar_status.Position:=ProgressBar_status.Position+1;

end;
//-----------------------------------------------------


if  (GLOBAL_FLAG=3) then   //׼������
begin
    Label_status.Caption:='��Ʊ���ڽ�������~~~~' ;
    ProgressBar_status.Position:=50;
end;
//-----------------------------------------------------

if  (GLOBAL_FLAG=4) then   //�������
begin

        GLOBAL_FLAG:=5; //���ڻ�ȡ����
        //������ȡ�����߳�
         flag:=true;
         quhaoflag:=false;
         radspanint:=pindaoint*1000;
        for i:=0 to high(MYQUH) do
        MYQUH[i].Resume;

      Label_status.Caption:='�������!׼����ȡ����~~' ;
      ProgressBar_status.Position:=60;
end;

//-----------------------------------------------------

if  (GLOBAL_FLAG=5) then   //������ȡ�����߳�
begin
    Label_status.Caption:='׼����ȡ����,�����ĵȴ�~~~~' ;
    ProgressBar_status.Position:=80;
end;
//-----------------------------------------------------
if  (GLOBAL_FLAG=6) then   //ȡ������
begin
Label_status.Caption:='���' ;
ProgressBar_status.Position:=100;


GLOBAL_FLAG:=0; //����״̬
        flag:=true;
     quhaoflag:=true;
    button1.Caption:='��ʼ';
    showmessage('��Ʊ���̽������뵽����·���ȡƱ��ַ����ȡƱ��ӡ��');

Label_status.Caption:='����' ;
ProgressBar_status.Position:=0;
end;


end;






procedure TForm1.Label11Click(Sender: TObject);
begin
ShellExecute(Application.Handle, nil, 'http://nuistqp.duapp.com', nil, nil, SW_SHOWNORMAL);
end;

end.
