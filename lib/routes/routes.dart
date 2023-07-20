import 'package:document_saver_app/screens/Login/forgot_password.dart';
import 'package:document_saver_app/screens/Login/register.dart';
import 'package:document_saver_app/screens/addDocument/add_document.dart';
import 'package:document_saver_app/screens/document_view/document_view.dart';
import 'package:document_saver_app/screens/home/home.dart';
import 'package:document_saver_app/screens/login/login.dart';
import 'package:flutter/material.dart';

const String loginPageRoute = "/login";
const String registerPageRoute = "/register";
const String forgotPasswordPageRoute = "/forgot-password";
const String homePageRoute = "/home";
const String addDocumentPageRoute = "/add-document";
const String documentViewPageRoute = "/document-view";

var routes = <String, WidgetBuilder>{
  loginPageRoute: (context) => const Login(),
  registerPageRoute: (context) => const Register(),
  forgotPasswordPageRoute: (context) => const ForgotPassword(),
  homePageRoute: (context) => const Home(),
  addDocumentPageRoute: (context) => const AddDocument(),
  documentViewPageRoute: (context) => const DocumentView(),
};
