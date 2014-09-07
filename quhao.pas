unit quhao;

interface

uses
  Classes,SysUtils,Windows;

type
  QUH = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation
uses unit1;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure QH.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ QH }

procedure QUH.Execute;
var
tempstr:string;
tempint:integer;
temptodaydate:string;
begin
temptodaydate:=todaydate+' 13:';
  { Place thread code here }
  while  not Terminated do
  begin
        if (quhaoflag) then
        self.Suspend;


        //----------------------------------------
            EnterCriticalSection(FLock); //进入临界区域
            tempint:= radspanint;
            radspanint:=radspanint+1;
            if (radspanint>pindaoint*1000+999) then
            begin
            quhaoflag:=true;
            GLOBAL_FLAG:=6;//取单结束
            end;
            LeaveCriticalSection(FLock); //退出临界区域
        //-----------------------------------------

       repeat
        if (quhaoflag) then
        break;
        tempstr:=CheckNumber(M_gh+MYHTTPEncode(Getrandomspan(tempint)));
       until(tempstr<>'');

       //todaydate:=formatDateTime('yyyymd',now)+' 13:';

       if (pos(temptodaydate,tempstr)>1) then
       begin
            quhaoflag:=true;
            GLOBAL_FLAG:=6;//取单结束
            P_info:=GetInfo(tempstr);

            tempstr:=PostPiao(M_gh,M_xm,M_tel,M_lx,inttostr(pindaoint),inttostr(tempint),P_info);

            if (tempstr<>'0') then
            begin
            Writetotxt(formatDateTime('yyyymmddhhnnss',now)+':'+M_gh+' '+M_xm+' '+M_tel+' '+M_lx+' '+inttostr(tempint)+' '+P_info+' http://172.16.102.207:81/quhao/history.jsp?id='+M_gh+MYHTTPEncode(Getrandomspan(tempint)));
            end;
            self.Suspend;
       end;



  end;



end;

end.
