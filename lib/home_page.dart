import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'diary_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //달력 보여주는 형식
  CalendarFormat calendarFormat = CalendarFormat.month;

  //선택된 날짜
  DateTime selectedDate = DateTime.now();

  //create text controller
  TextEditingController createTextController = TextEditingController();

  //update text controller
  TextEditingController updateTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryService>(
      builder: (context, diaryService, child){
        List<Diary> diaryList = diaryService.getByDate(selectedDate);
        return Scaffold(
          //키보드가 올라올때 화면 밀지 않도록 만들기(overflow방지)
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                TableCalendar(
                    focusedDay: selectedDate,
                    firstDay: DateTime.utc(2010,10,16),
                    lastDay: DateTime.utc(2030,12,31),
                    calendarFormat: calendarFormat,
                    onFormatChanged: (format){
                      //달력 형식 변경
                      setState(() {
                        calendarFormat = format;
                      });
                    },
                    eventLoader: (date){
                      //각 날짜에 해당하는 diaryList 보여주기
                      return diaryService.getByDate(date);
                    },
                    calendarStyle: CalendarStyle(
                      //today 색상 제거
                      todayTextStyle: TextStyle(color: Colors.black),
                      todayDecoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    selectedDayPredicate: (day){
                      return isSameDay(selectedDate, day);
                    },
                    onDaySelected: (_, focusedDay){
                      setState(() {
                        selectedDate = focusedDay;
                      });
                    },
                ),
                Divider(height: 1,),

                //선택한 날짜의 일기 목록
                Expanded(
                  child: diaryList.isEmpty
                    ? Center(child: Text("한 줄 일기를 작성해 주세요", style: TextStyle(color: Colors.grey, fontSize: 18),),)
                    : ListView.separated(
                      itemBuilder: (context, index){
                        //역순으로 보여주기
                        int i = diaryList.length - index -1;
                        Diary diary = diaryList[i];
                        return ListTile(
                          //text
                          title: Text(
                            diary.text,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                          //createdAt
                          trailing: Text(
                            DateFormat('kk:mm').format(diary.createAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: (){
                            print("수정하러 간다");
                            showUpdateDialog(diaryService, diary);
                          },
                          //꾹 누리면 delete
                          onLongPress: (){
                            print("삭제 하러 간다");
                            showDeleteDialog(diaryService, diary);
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index){
                        return Divider(height: 1,);
                      },
                      itemCount: diaryList.length,
                    ),
                ),
              ],
            ),
          ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.create),
          backgroundColor: Colors.indigo,
          onPressed: (){
            showCreateDialog(diaryService);
          },
        ),
        );
      }
    );
  }

  //작성하기
  //엔터를 누르거나 작성 버튼을 누르는 경우 호출
  void createDiary(DiaryService diaryService){
    //앞뒤 공백 제거
    String newText = createTextController.text.trim();
    if (newText.isNotEmpty){
      diaryService.create(newText, selectedDate);
      createTextController.text = "";
    }
  }

  //수정하기
  //엔터를 누르거나 수정버튼을 누르는 경우 호출
  void updateDiary(DiaryService diaryService, Diary diary){
    //앞뒤 공백 삭제
    String updatedText = updateTextController.text.trim();
    if (updatedText.isNotEmpty){
      diaryService.update(diary.createAt, updatedText);
    }
  }

  //작성 다이얼로그 보여주기
  void showCreateDialog(DiaryService diaryService){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("일기 작성"),
            content: TextField(
              controller: createTextController,
              autofocus: true,
              cursorColor: Colors.indigo,
              decoration: InputDecoration(
                hintText: "한 줄 일기를 작성해 주세요",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                )
              ),
              onSubmitted: (_){
                //엔터 누를 때 작성하기
                createDiary(diaryService);
                Navigator.pop(context);
              },
            ),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("취소", style: TextStyle(color: Colors.indigo),)),
              TextButton(onPressed: (){
                createDiary(diaryService);
                Navigator.pop(context);
              }, child: Text("작성", style: TextStyle(color: Colors.indigo),)),
            ],
          );
        }
    );
  }

  //수정 다이얼로그 보여주기
  void showUpdateDialog(DiaryService diaryService, Diary diary){
    showDialog(
      context: context,
      builder: (context){
        updateTextController.text = diary.text;
        return AlertDialog(
          title: Text("일기 수정"),
          content: TextField(
            autofocus: true,
            controller: updateTextController,
            //커서 색상
            cursorColor: Colors.indigo,
            decoration: InputDecoration(
              hintText: "한 줄 일기를 작성해 주세요",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.indigo),
              ),
            ),
            onSubmitted: (_){
              //엔터 누를 때 수정하기
              updateDiary(diaryService, diary);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text("취소", style: TextStyle(color: Colors.indigo),)),
            TextButton(onPressed: (){
              updateDiary(diaryService, diary);
              Navigator.pop(context);
            }, child: Text("수정", style: TextStyle(color: Colors.indigo),)),

          ],
        );
      }
    );
  }

  //삭제하기
  void showDeleteDialog(DiaryService diaryService, Diary diary){
    showDialog(
        context: context,
        builder: (context){
          updateTextController.text = diary.text;
          return AlertDialog(
            title: Text("일기 삭제"),
            content: Text('"${diary.text}"를 삭제 하시겠습니까?'),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("취소", style: TextStyle(fontSize: 18, color: Colors.indigo),)),
              TextButton(onPressed: (){
                diaryService.delete(diary.createAt);
                Navigator.pop(context);
              }, child: Text("삭제", style: TextStyle(fontSize: 18, color: Colors.indigo),)),
            ],
          );
        }
    );
  }

}

