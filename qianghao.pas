unit qianghao;

interface

uses
  Classes,SysUtils,Windows;

type
  QH = class(TThread)
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

procedure QH.Execute;
var
tempstr:string;
tempint:integer;
begin
  { Place thread code here }
  while  not Terminated do
  begin
        if (flag) then
        self.Suspend;


        //----------------------------------------
            EnterCriticalSection(FLock); //进入临界区域
            tempint:= radspanint;
            radspanint:=radspanint+1;
            if (radspanint>pindaoint*1000+999) then
            radspanint:=pindaoint*1000;

            LeaveCriticalSection(FLock); //退出临界区域
        //-----------------------------------------


       tempstr:=GetNumber(M_gh+Getrandomspan(tempint),M_xm,M_tel,M_lx);


       if (GLOBAL_FLAG<>3) then
       begin
            continue;
       end;

       if (tempstr='') then    //获取失败
       begin
          //  form1.Memo1.Lines.Add(inttostr(tempint)+'err');
            continue;
       end;

       if (pos('达到上限',tempstr)>1) then
       begin
          //  form1.Memo1.Lines.Add(inttostr(tempint)+'gk');
            flag:=true;
            GLOBAL_FLAG:=4;//已经抢到
            self.Suspend;
       end;



  end;



end;

end.
