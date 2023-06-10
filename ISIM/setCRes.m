function setCRes(CResNum)
    mustBeMember(CResNum,[0 1 2]);
    global CRes;
    CRes = CResNum;
end