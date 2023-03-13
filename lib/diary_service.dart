import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Diary{
  String text;  //내용
  DateTime createAt;  //작성 시간
  Diary({
    required this.text,
    required this.createAt
  });
}

class DiaryService extends ChangeNotifier{
  //Diary 목록
  List<Diary> diaryList = [];

  //특정 날짜의 diary조회
  List<Diary> getByDate(DateTime date){
    return diaryList
        .where((diary) => isSameDay(date, diary.createAt))
        .toList();
  }

  //Diary 작성
  void create(String text, DateTime selectDate){
    DateTime now = DateTime.now();

    //선택된 날짜(selectedDate)에 현재 시간으로 추가
    DateTime createAt = DateTime(
      selectDate.year,
      selectDate.month,
      selectDate.day,
      now.hour,
      now.minute,
      now.second
    );

    Diary diary = Diary(
      text: text,
      createAt: createAt,
    );

    diaryList.add(diary);
    notifyListeners();
  }

  //Diary 수정
  void update(DateTime createAt, String newContent){
    //createAt은 중복될 일이 없기 때문에 createAt을 고유 식별자로 사용
    //createAt이 일치하는 diary 조회
    Diary diary = diaryList.firstWhere((diary) => diary.createAt == createAt);
    //text 수정
    diary.text = newContent;
    notifyListeners();
  }

  //Diary 삭제
  void delete(DateTime createAt){
    diaryList.removeWhere((diary) => diary.createAt == createAt);
    notifyListeners();
  }

}