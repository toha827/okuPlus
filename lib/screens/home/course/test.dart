import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/models/course.dart';
import 'dart:io';
import 'package:flutterapp/models/top.dart';
import 'package:flutterapp/shared/pdf/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutterapp/services/users.dart';
import 'package:flutterapp/models/question.dart';
import 'package:flutterapp/screens/home/course/course_detail.dart';
import 'package:flutterapp/shared/pdf/pdf.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Test extends StatefulWidget {
  List<Question> questions;


  Test({this.questions});

  @override
  _TestState createState() => _TestState(questinos: questions);
}

class _TestState extends State<Test> {

  _TestState({this.questinos});
  List<String> userAnswers = [];
  List<int> userAnswersRadio = [];
  List arr = ["1", "2", "2", "2","2", "2","2", "2"];
  List<Question> questinos;
  String uid;
  Top top;
  TopService topService;
  bool isExpand = true;
  Directory _downloadsDirectory;

  @override
  void initState() {
    questinos.forEach((element) {
      setState(() {
        userAnswers.add("");
        userAnswersRadio.add(-1);
      });
    });
    FirebaseAuth.instance.onAuthStateChanged.listen((event) {
      setState(() {
        uid = event.uid;
        topService = TopService(uid: uid);
        topService.teacherCoursesStream.listen((event) {
          setState(() {
            top = event;
          });
        });
      } );
    });

    super.initState();
    initDownloadsDirectoryState();

  }

  Future<Question> createQuestionDialog(BuildContext context, int score, int full){
    Question newQuestion = new Question();
    TextEditingController descriptionTextController = TextEditingController();
    TextEditingController answerTextController = TextEditingController();
    TextEditingController variantTextController = TextEditingController();
    List<String> variants = [];
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("You have scored " + score.toString() + "/" + full.toString()),
        content: Column(
          children: <Widget>[
            ]
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 3.0,
            child: Text("Download Certificate"),
            onPressed: (){
              generatePdfAndView(context, "'");
            },
          )
        ],
      );
    });
  }

  Future<Question> createFinishDialog(BuildContext context, String score){
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("You have get certificate in " + score.toString()),
        content: Column(
            children: <Widget>[
            ]
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 3.0,
            child: Text("Ok"),
            onPressed: (){
              Navigator.of(context).pop();
            },
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          title: Text('OkuPlus'),
          backgroundColor: Colors.blue[400],
          elevation: 0.0,
          actions: <Widget>[

          ],
        ),
        body: ListView.builder(
          itemBuilder: (context, position) {
            return Card(
              child: listItem(position, questinos[position].description, questinos[position]),
            );
          },
          itemCount: questinos.length,
        ),
      floatingActionButton: RaisedButton(
        child: Text("End Test"),
        onPressed: () async {
          int score = 0;
          questinos.forEach((element1) {
            userAnswers.forEach((element2) {

              if (element1.answer == element2){
                score++;
              }
            });
          });
          createQuestionDialog(context,score,userAnswers.length);
//          Fluttertoast.showToast(
//            msg: "You Have Scored " + score.toString() + " of " + questinos.length.toString(),
//            toastLength: Toast.LENGTH_SHORT,
//            webBgColor: "#e74c3c",
//            timeInSecForIosWeb: 1,
//          );
          if (score == userAnswers.length){
            Top newTop = new Top(name: top.name, score: top == null ? 0 : top.score + 50);
            topService.updateTop(newTop);
          }
        },
      ),
    );
  }

  Widget listItem(int id, String title, Question question) => Container(
      height: 300.0,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ExpansionTile(
              key: PageStorageKey(this.widget.key),
              title: Container(
                  width: double.infinity,

                  child: Text(title,style: TextStyle(fontSize: 18))
              ),
              trailing: Icon(Icons.arrow_drop_down,size: 32,color: Colors.pink,),
              onExpansionChanged: (value){
                setState(() {
                  isExpand=value;
                });
              },
              children: getStudents(id, question)
          ),
          ListTile(
            title: TextField(
              onChanged: (val){
                userAnswers[id] = val;
              },
            ),
            subtitle: Text("Answer"),
          )
        ],
      )
  );

  List<Widget> getStudents(int id, Question question) {
    List<Widget> ll = [];
    for(int i = 0; i < question.questions.length; i++){
      ll.add(
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              (i + 1).toString() + ")" + questinos[id].questions[i],
              style: new TextStyle(fontSize: 16.0),
            )
          ],
        ),
      );
    }
    return ll;
  }

  Future<void> initDownloadsDirectoryState() async {
    Directory downloadsDirectory;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    } on PlatformException {
      print('Could not get the downloads directory');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _downloadsDirectory = downloadsDirectory;
    });
  }

  generatePdfAndView(context, String courseName) async {
    final pw.Document doc = pw.Document();
    if (await Permission.storage.request().isGranted) {
      doc.addPage(pw.MultiPage(
          pageFormat:
          PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          header: (pw.Context context) {
            if (context.pageNumber == 1) {
              return null;
            }
            return pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: const pw.EdgeInsets.only(
                    bottom: 3.0 * PdfPageFormat.mm),
                padding: const pw.EdgeInsets.only(
                    bottom: 3.0 * PdfPageFormat.mm),
                decoration: const pw.BoxDecoration(
                    border: pw.BoxBorder(
                        bottom: true, width: 0.5, color: PdfColors.grey)),
                child: pw.Text('Portable Document Format',
                    style: pw.Theme
                        .of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.grey)));
          },
          footer: (pw.Context context) {
            return pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                child: pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.Theme
                        .of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.grey)));
          },
          build: (pw.Context context) =>
          <pw.Widget>[
            pw.Header(
                level: 0,
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: <pw.Widget>[
                      pw.Text('Portable Document Format', textScaleFactor: 2),
                      pw.PdfLogo()
                    ])),
            pw.Paragraph(
                text:
                'The Portable Document Format (PDF) is a file format developed by Adobe in the 1990s to present documents, including text formatting and images, in a manner independent of application software, hardware, and operating systems. Based on the PostScript language, each PDF file encapsulates a complete description of a fixed-layout flat document, including the text, fonts, vector graphics, raster images and other information needed to display it. PDF was standardized as an open format, ISO 32000, in 2008, and no longer requires any royalties for its implementation.'),
            pw.Paragraph(
                text:
                'Today, PDF files may contain a variety of content besides flat text and graphics including logical structuring elements, interactive elements such as annotations and form-fields, layers, rich media (including video content) and three dimensional objects using U3D or PRC, and various other data formats. The PDF specification also provides for encryption and digital signatures, file attachments and metadata to enable workflows requiring these features.'),
            pw.Header(level: 1, text: 'History and standardization'),
            pw.Paragraph(
                text:
                "Adobe Systems made the PDF specification available free of charge in 1993. In the early years PDF was popular mainly in desktop publishing workflows, and competed with a variety of formats such as DjVu, Envoy, Common Ground Digital Paper, Farallon Replica and even Adobe's own PostScript format."),
            pw.Paragraph(
                text:
                'PDF was a proprietary format controlled by Adobe until it was released as an open standard on July 1, 2008, and published by the International Organization for Standardization as ISO 32000-1:2008, at which time control of the specification passed to an ISO Committee of volunteer industry experts. In 2008, Adobe published a Public Patent License to ISO 32000-1 granting royalty-free rights for all patents owned by Adobe that are necessary to make, use, sell, and distribute PDF compliant implementations.'),
            pw.Paragraph(
                text:
                "PDF 1.7, the sixth edition of the PDF specification that became ISO 32000-1, includes some proprietary technologies defined only by Adobe, such as Adobe XML Forms Architecture (XFA) and JavaScript extension for Acrobat, which are referenced by ISO 32000-1 as normative and indispensable for the full implementation of the ISO 32000-1 specification. These proprietary technologies are not standardized and their specification is published only on Adobe's website. Many of them are also not supported by popular third-party implementations of PDF."),
            pw.Paragraph(
                text:
                'On July 28, 2017, ISO 32000-2:2017 (PDF 2.0) was published. ISO 32000-2 does not include any proprietary technologies as normative references.'),
            pw.Header(level: 1, text: 'Technical foundations'),
            pw.Paragraph(text: 'The PDF combines three technologies:'),
            pw.Bullet(
                text:
                'A subset of the PostScript page description programming language, for generating the layout and graphics.'),
            pw.Bullet(
                text:
                'A font-embedding/replacement system to allow fonts to travel with the documents.'),
            pw.Bullet(
                text:
                'A structured storage system to bundle these elements and any associated content into a single file, with data compression where appropriate.'),
            pw.Header(level: 2, text: 'PostScript'),
            pw.Paragraph(
                text:
                'PostScript is a page description language run in an interpreter to generate an image, a process requiring many resources. It can handle graphics and standard features of programming languages such as if and loop commands. PDF is largely based on PostScript but simplified to remove flow control features like these, while graphics commands such as lineto remain.'),
            pw.Paragraph(
                text:
                'Often, the PostScript-like PDF code is generated from a source PostScript file. The graphics commands that are output by the PostScript code are collected and tokenized. Any files, graphics, or fonts to which the document refers also are collected. Then, everything is compressed to a single file. Therefore, the entire PostScript world (fonts, layout, measurements) remains intact.'),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Paragraph(
                      text:
                      'As a document format, PDF has several advantages over PostScript:'),
                  pw.Bullet(
                      text:
                      'PDF contains tokenized and interpreted results of the PostScript source code, for direct correspondence between changes to items in the PDF page description and changes to the resulting page appearance.'),
                  pw.Bullet(
                      text:
                      'PDF (from version 1.4) supports graphic transparency; PostScript does not.'),
                  pw.Bullet(
                      text:
                      'PostScript is an interpreted programming language with an implicit global state, so instructions accompanying the description of one page can affect the appearance of any following page. Therefore, all preceding pages in a PostScript document must be processed to determine the correct appearance of a given page, whereas each page in a PDF document is unaffected by the others. As a result, PDF viewers allow the user to quickly jump to the final pages of a long document, whereas a PostScript viewer needs to process all pages sequentially before being able to display the destination page (unless the optional PostScript Document Structuring Conventions have been carefully complied with).'),
                ]),
            pw.Header(level: 1, text: 'Content'),
            pw.Paragraph(
                text:
                'A PDF file is often a combination of vector graphics, text, and bitmap graphics. The basic types of content in a PDF are:'),
            pw.Bullet(
                text:
                'Text stored as content streams (i.e., not encoded in plain text)'),
            pw.Bullet(
                text:
                'Vector graphics for illustrations and designs that consist of shapes and lines'),
            pw.Bullet(
                text:
                'Raster graphics for photographs and other types of image'),
            pw.Bullet(text: 'Multimedia objects in the document'),
            pw.Paragraph(
                text:
                'In later PDF revisions, a PDF document can also support links (inside document or web page), forms, JavaScript (initially available as plugin for Acrobat 3.0), or any other types of embedded contents that can be handled using plug-ins.'),
            pw.Paragraph(
                text:
                'PDF 1.6 supports interactive 3D documents embedded in the PDF - 3D drawings can be embedded using U3D or PRC and various other data formats.'),
            pw.Paragraph(
                text:
                'Two PDF files that look similar on a computer screen may be of very different sizes. For example, a high resolution raster image takes more space than a low resolution one. Typically higher resolution is needed for printing documents than for displaying them on screen. Other things that may increase the size of a file is embedding full fonts, especially for Asiatic scripts, and storing text as graphics. '),
            pw.Header(
                level: 1, text: 'File formats and Adobe Acrobat versions'),
            pw.Paragraph(
                text:
                'The PDF file format has changed several times, and continues to evolve, along with the release of new versions of Adobe Acrobat. There have been nine versions of PDF and the corresponding version of the software:'),
            pw.Table.fromTextArray(context: context, data: const <List<String>>[
              <String>['Date', 'PDF Version', 'Acrobat Version'],
              <String>['1993', 'PDF 1.0', 'Acrobat 1'],
              <String>['1994', 'PDF 1.1', 'Acrobat 2'],
              <String>['1996', 'PDF 1.2', 'Acrobat 3'],
              <String>['1999', 'PDF 1.3', 'Acrobat 4'],
              <String>['2001', 'PDF 1.4', 'Acrobat 5'],
              <String>['2003', 'PDF 1.5', 'Acrobat 6'],
              <String>['2005', 'PDF 1.6', 'Acrobat 7'],
              <String>['2006', 'PDF 1.7', 'Acrobat 8'],
              <String>['2008', 'PDF 1.7', 'Acrobat 9'],
              <String>['2009', 'PDF 1.7', 'Acrobat 9.1'],
              <String>['2010', 'PDF 1.7', 'Acrobat X'],
              <String>['2012', 'PDF 1.7', 'Acrobat XI'],
              <String>['2017', 'PDF 2.0', 'Acrobat DC'],
            ]),
            pw.Padding(padding: const pw.EdgeInsets.all(10)),
            pw.Paragraph(
                text:
                'Text is available under the Creative Commons Attribution Share Alike License.')
          ]));
      Directory appDocDirectory = await getExternalStorageDirectory();
      new Directory(appDocDirectory.path + '/' + 'dir').create(recursive: true)
          .then((Directory directory) {
        print('Path of New Dir: ' + appDocDirectory.path);
        final File file = File(
            appDocDirectory.path + '/' + courseName + 'Certificate.pdf');
        file.writeAsBytesSync(doc.save());
        createFinishDialog(context, file.path.toString());
        // Navigator.push(context, MaterialPageRoute(
      //      builder: (context) => PdfViewerPage(path: file.path)));
      });
    }
  }
}
