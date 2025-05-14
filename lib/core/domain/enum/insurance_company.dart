enum InsuranceCompany{
  samsung,hanwha,kyobo,nonghyup,miraeAsset,tongyang,dgb,kb,hana,shinhan,aia,lina,chubb,ibk,heungkuk,samsungFire,hyundai,
  dbInsu,kbInsu,meritz,hanwhaInsu,nhInsu,mgInsu,lotte,axa,aig,carrot,hanaInsu,hungkukInsu,etc;

  @override
  String toString()=>switch(this){

    InsuranceCompany.samsung =>'삼성생명',
    InsuranceCompany.hanwha =>'한화생명',
    InsuranceCompany.kyobo =>'교보생명',
    InsuranceCompany.nonghyup =>'NH농협생명',
    InsuranceCompany.miraeAsset =>'미래에셋생명',
    InsuranceCompany.tongyang =>'동양생명',
    InsuranceCompany.dgb =>'DGB생명',
    InsuranceCompany.kb =>'KB라이프',
    InsuranceCompany.hana =>'하나생명',
    InsuranceCompany.shinhan =>'신한생명',
    InsuranceCompany.aia =>'AIA생명',
    InsuranceCompany.lina =>'라이나생명',
    InsuranceCompany.chubb =>'처브라이프',
    InsuranceCompany.ibk =>'IBK연금',
    InsuranceCompany.heungkuk =>'흥국생명',
    InsuranceCompany.samsungFire =>'삼성화재',
    InsuranceCompany.hyundai =>'현대해상',
    InsuranceCompany.dbInsu =>'DB손해',
    InsuranceCompany.kbInsu =>'KB손해',
    InsuranceCompany.meritz =>'메리츠화재',
    InsuranceCompany.hanwhaInsu =>'한화손해',
    InsuranceCompany.nhInsu =>'NH손해',
    InsuranceCompany.mgInsu =>'MG손해',
    InsuranceCompany.lotte =>'롯데손해',
    InsuranceCompany.axa =>'AXA',
    InsuranceCompany.aig =>'AIG손해',
    InsuranceCompany.carrot =>'캐롯손해',
    InsuranceCompany.hanaInsu =>'하나손해',
    InsuranceCompany.hungkukInsu =>'흥국손해',
    InsuranceCompany.etc =>'기타',
  };
}
