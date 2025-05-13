import 'package:flutter/material.dart';
import 'package:withme/presentation/home/customer/customer_page.dart';
import 'package:withme/presentation/home/dash_board/dash_board_page.dart';

import '../../../presentation/home/prospect/screen/prospect_page.dart';
import '../../../presentation/home/search/search_page.dart';
import '../../ui/icon/const.dart';


enum HomeMenu {
  prospect(name: 'Prospect', iconPath: IconsPath.prospectPerson),
  customer(name: 'Customer', iconPath: IconsPath.customerPerson),
  search(name: 'Search', iconPath: IconsPath.searchPerson),
  dashBoard(name: 'DashBoard', iconPath: IconsPath.dashBoard);

  final String name;
  final String iconPath;

  const HomeMenu({required this.name, required this.iconPath});

  Widget get toWidget => switch (this) {
    HomeMenu.prospect => ProspectPage(),
    HomeMenu.customer => CustomerPage(),
    HomeMenu.search => SearchPage(),
    HomeMenu.dashBoard => DashBoardPage(),
  };
}

//1단계: 유치 단계 (Acquisition)
//설명: 잠재 고객을 발굴하고 보험 상품에 관심을 유도하여 실제 고객으로 전환하는 단계입니다.
//관련 활동: 마케팅, 상담, 견적 제공, 계약 체결 등
//다른 용어: 리드 생성(Lead Generation), 영업 기회 발굴
//
//2단계: 유지 단계 (Retention)
//설명: 이미 가입한 고객과의 관계를 유지하고, 만족도를 높이며 지속적인 보험료 납입과 갱신을 유도하는 단계입니다.
//관련 활동: 고객 상담, 보상 처리, 만족도 조사, 지속적인 커뮤니케이션 등
//다른 용어: 관계 강화, 고객 만족 관리
//
//3단계: 확장 단계 (Expansion)
//설명: 기존 고객에게 추가 상품을 제안하거나 업셀링/크로스셀링을 통해 수익성을 높이는 단계입니다.
//관련 활동: 추가 보험 제안, 가족 보험 추천, 보장 업그레이드 등
//다른 용어: 고객 가치 증대, 고객 생애가치(LTV) 증대
