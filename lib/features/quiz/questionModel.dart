class Questionmodel {
final String question;
final String option1;
final String option2;
final String option3;
final String option4;
final String correctOpt;
final String? queImgUrl;
 int queMoney;
final String explanation;

Questionmodel({
  required this.question,
required this.option1,
required this.option2,
required this.option3,
required this.option4,
required this.correctOpt,
 this.queImgUrl = "https://images.unsplash.com/photo-1477587458883-47145ed94245?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
required this.queMoney,
required this.explanation,
});

}
