function setBRes(BResNum)
    mustBeMember(BResNum,[0 1]);
    global BRes;
    BRes = BResNum;
end