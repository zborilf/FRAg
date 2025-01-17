# Generated from MAS2Java.g4 by ANTLR 4.9
# encoding: utf-8
from antlr4 import *
from io import StringIO
import sys
if sys.version_info[1] > 5:
	from typing import TextIO
else:
	from typing.io import TextIO


def serializedATN():
    with StringIO() as buf:
        buf.write("\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3\27")
        buf.write("l\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b")
        buf.write("\t\b\4\t\t\t\4\n\t\n\4\13\t\13\4\f\t\f\3\2\3\2\3\2\3\2")
        buf.write("\5\2\35\n\2\3\2\5\2 \n\2\3\2\5\2#\n\2\3\2\3\2\3\2\3\3")
        buf.write("\3\3\3\3\3\3\3\4\3\4\3\4\3\4\3\5\3\5\3\5\3\5\3\5\5\5\65")
        buf.write("\n\5\3\6\3\6\3\6\6\6:\n\6\r\6\16\6;\3\7\3\7\5\7@\n\7\3")
        buf.write("\7\5\7C\n\7\3\7\5\7F\n\7\3\7\5\7I\n\7\3\7\5\7L\n\7\3\7")
        buf.write("\3\7\5\7P\n\7\3\7\5\7S\n\7\3\7\3\7\3\b\3\b\7\bY\n\b\f")
        buf.write("\b\16\b\\\13\b\3\b\3\b\3\t\3\t\3\t\3\n\3\n\3\n\3\13\3")
        buf.write("\13\3\13\3\f\3\f\3\f\3\f\3Z\2\r\2\4\6\b\n\f\16\20\22\24")
        buf.write("\26\2\2\2m\2\30\3\2\2\2\4\'\3\2\2\2\6+\3\2\2\2\b/\3\2")
        buf.write("\2\2\n\66\3\2\2\2\f=\3\2\2\2\16V\3\2\2\2\20_\3\2\2\2\22")
        buf.write("b\3\2\2\2\24e\3\2\2\2\26h\3\2\2\2\30\31\7\3\2\2\31\32")
        buf.write("\7\23\2\2\32\34\7\4\2\2\33\35\5\4\3\2\34\33\3\2\2\2\34")
        buf.write("\35\3\2\2\2\35\37\3\2\2\2\36 \5\6\4\2\37\36\3\2\2\2\37")
        buf.write(" \3\2\2\2 \"\3\2\2\2!#\5\b\5\2\"!\3\2\2\2\"#\3\2\2\2#")
        buf.write("$\3\2\2\2$%\5\n\6\2%&\7\5\2\2&\3\3\2\2\2\'(\7\6\2\2()")
        buf.write("\7\7\2\2)*\7\23\2\2*\5\3\2\2\2+,\7\b\2\2,-\7\7\2\2-.\7")
        buf.write("\26\2\2.\7\3\2\2\2/\60\7\t\2\2\60\61\7\7\2\2\61\64\7\23")
        buf.write("\2\2\62\63\7\n\2\2\63\65\7\23\2\2\64\62\3\2\2\2\64\65")
        buf.write("\3\2\2\2\65\t\3\2\2\2\66\67\7\13\2\2\679\7\7\2\28:\5\f")
        buf.write("\7\298\3\2\2\2:;\3\2\2\2;9\3\2\2\2;<\3\2\2\2<\13\3\2\2")
        buf.write("\2=?\7\23\2\2>@\7\24\2\2?>\3\2\2\2?@\3\2\2\2@B\3\2\2\2")
        buf.write("AC\5\16\b\2BA\3\2\2\2BC\3\2\2\2CE\3\2\2\2DF\5\20\t\2E")
        buf.write("D\3\2\2\2EF\3\2\2\2FH\3\2\2\2GI\5\22\n\2HG\3\2\2\2HI\3")
        buf.write("\2\2\2IK\3\2\2\2JL\5\24\13\2KJ\3\2\2\2KL\3\2\2\2LO\3\2")
        buf.write("\2\2MN\7\f\2\2NP\7\25\2\2OM\3\2\2\2OP\3\2\2\2PR\3\2\2")
        buf.write("\2QS\5\26\f\2RQ\3\2\2\2RS\3\2\2\2ST\3\2\2\2TU\7\r\2\2")
        buf.write("U\r\3\2\2\2VZ\7\16\2\2WY\13\2\2\2XW\3\2\2\2Y\\\3\2\2\2")
        buf.write("Z[\3\2\2\2ZX\3\2\2\2[]\3\2\2\2\\Z\3\2\2\2]^\7\17\2\2^")
        buf.write("\17\3\2\2\2_`\7\20\2\2`a\7\23\2\2a\21\3\2\2\2bc\7\21\2")
        buf.write("\2cd\7\23\2\2d\23\3\2\2\2ef\7\22\2\2fg\7\23\2\2g\25\3")
        buf.write("\2\2\2hi\7\n\2\2ij\7\23\2\2j\27\3\2\2\2\17\34\37\"\64")
        buf.write(";?BEHKORZ")
        return buf.getvalue()


class MAS2JavaParser ( Parser ):

    grammarFileName = "MAS2Java.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "'MAS'", "'{'", "'}'", "'infrastructure'", 
                     "':'", "'environment'", "'executionControl'", "'at'", 
                     "'agents'", "'#'", "';'", "'['", "']'", "'agentArchClass'", 
                     "'beliefBaseClass'", "'agentClass'" ]

    symbolicNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "ID", "FILENAME", "NUMBER", "STRING", 
                      "WS" ]

    RULE_mas = 0
    RULE_infrastructure = 1
    RULE_environment = 2
    RULE_exec_control = 3
    RULE_agents = 4
    RULE_agent = 5
    RULE_agt_options = 6
    RULE_agt_arch_class = 7
    RULE_agt_belief_base_class = 8
    RULE_agt_class = 9
    RULE_agt_at = 10

    ruleNames =  [ "mas", "infrastructure", "environment", "exec_control", 
                   "agents", "agent", "agt_options", "agt_arch_class", "agt_belief_base_class", 
                   "agt_class", "agt_at" ]

    EOF = Token.EOF
    T__0=1
    T__1=2
    T__2=3
    T__3=4
    T__4=5
    T__5=6
    T__6=7
    T__7=8
    T__8=9
    T__9=10
    T__10=11
    T__11=12
    T__12=13
    T__13=14
    T__14=15
    T__15=16
    ID=17
    FILENAME=18
    NUMBER=19
    STRING=20
    WS=21

    def __init__(self, input:TokenStream, output:TextIO = sys.stdout):
        super().__init__(input, output)
        self.checkVersion("4.9")
        self._interp = ParserATNSimulator(self, self.atn, self.decisionsToDFA, self.sharedContextCache)
        self._predicates = None




    class MasContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def ID(self):
            return self.getToken(MAS2JavaParser.ID, 0)

        def agents(self):
            return self.getTypedRuleContext(MAS2JavaParser.AgentsContext,0)


        def infrastructure(self):
            return self.getTypedRuleContext(MAS2JavaParser.InfrastructureContext,0)


        def environment(self):
            return self.getTypedRuleContext(MAS2JavaParser.EnvironmentContext,0)


        def exec_control(self):
            return self.getTypedRuleContext(MAS2JavaParser.Exec_controlContext,0)


        def getRuleIndex(self):
            return MAS2JavaParser.RULE_mas

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterMas" ):
                listener.enterMas(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitMas" ):
                listener.exitMas(self)




    def mas(self):

        localctx = MAS2JavaParser.MasContext(self, self._ctx, self.state)
        self.enterRule(localctx, 0, self.RULE_mas)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 22
            self.match(MAS2JavaParser.T__0)
            self.state = 23
            self.match(MAS2JavaParser.ID)
            self.state = 24
            self.match(MAS2JavaParser.T__1)
            self.state = 26
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAS2JavaParser.T__3:
                self.state = 25
                self.infrastructure()


            self.state = 29
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAS2JavaParser.T__5:
                self.state = 28
                self.environment()


            self.state = 32
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAS2JavaParser.T__6:
                self.state = 31
                self.exec_control()


            self.state = 34
            self.agents()
            self.state = 35
            self.match(MAS2JavaParser.T__2)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class InfrastructureContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def ID(self):
            return self.getToken(MAS2JavaParser.ID, 0)

        def getRuleIndex(self):
            return MAS2JavaParser.RULE_infrastructure

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterInfrastructure" ):
                listener.enterInfrastructure(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitInfrastructure" ):
                listener.exitInfrastructure(self)




    def infrastructure(self):

        localctx = MAS2JavaParser.InfrastructureContext(self, self._ctx, self.state)
        self.enterRule(localctx, 2, self.RULE_infrastructure)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 37
            self.match(MAS2JavaParser.T__3)
            self.state = 38
            self.match(MAS2JavaParser.T__4)
            self.state = 39
            self.match(MAS2JavaParser.ID)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class EnvironmentContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def STRING(self):
            return self.getToken(MAS2JavaParser.STRING, 0)

        def getRuleIndex(self):
            return MAS2JavaParser.RULE_environment

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterEnvironment" ):
                listener.enterEnvironment(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitEnvironment" ):
                listener.exitEnvironment(self)




    def environment(self):

        localctx = MAS2JavaParser.EnvironmentContext(self, self._ctx, self.state)
        self.enterRule(localctx, 4, self.RULE_environment)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 41
            self.match(MAS2JavaParser.T__5)
            self.state = 42
            self.match(MAS2JavaParser.T__4)
            self.state = 43
            self.match(MAS2JavaParser.STRING)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class Exec_controlContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def ID(self, i:int=None):
            if i is None:
                return self.getTokens(MAS2JavaParser.ID)
            else:
                return self.getToken(MAS2JavaParser.ID, i)

        def getRuleIndex(self):
            return MAS2JavaParser.RULE_exec_control

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterExec_control" ):
                listener.enterExec_control(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitExec_control" ):
                listener.exitExec_control(self)




    def exec_control(self):

        localctx = MAS2JavaParser.Exec_controlContext(self, self._ctx, self.state)
        self.enterRule(localctx, 6, self.RULE_exec_control)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 45
            self.match(MAS2JavaParser.T__6)
            self.state = 46
            self.match(MAS2JavaParser.T__4)
            self.state = 47
            self.match(MAS2JavaParser.ID)
            self.state = 50
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAS2JavaParser.T__7:
                self.state = 48
                self.match(MAS2JavaParser.T__7)
                self.state = 49
                self.match(MAS2JavaParser.ID)


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class AgentsContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def agent(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(MAS2JavaParser.AgentContext)
            else:
                return self.getTypedRuleContext(MAS2JavaParser.AgentContext,i)


        def getRuleIndex(self):
            return MAS2JavaParser.RULE_agents

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAgents" ):
                listener.enterAgents(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAgents" ):
                listener.exitAgents(self)




    def agents(self):

        localctx = MAS2JavaParser.AgentsContext(self, self._ctx, self.state)
        self.enterRule(localctx, 8, self.RULE_agents)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 52
            self.match(MAS2JavaParser.T__8)
            self.state = 53
            self.match(MAS2JavaParser.T__4)
            self.state = 55 
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while True:
                self.state = 54
                self.agent()
                self.state = 57 
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if not (_la==MAS2JavaParser.ID):
                    break

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class AgentContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def ID(self):
            return self.getToken(MAS2JavaParser.ID, 0)

        def FILENAME(self):
            return self.getToken(MAS2JavaParser.FILENAME, 0)

        def agt_options(self):
            return self.getTypedRuleContext(MAS2JavaParser.Agt_optionsContext,0)


        def agt_arch_class(self):
            return self.getTypedRuleContext(MAS2JavaParser.Agt_arch_classContext,0)


        def agt_belief_base_class(self):
            return self.getTypedRuleContext(MAS2JavaParser.Agt_belief_base_classContext,0)


        def agt_class(self):
            return self.getTypedRuleContext(MAS2JavaParser.Agt_classContext,0)


        def NUMBER(self):
            return self.getToken(MAS2JavaParser.NUMBER, 0)

        def agt_at(self):
            return self.getTypedRuleContext(MAS2JavaParser.Agt_atContext,0)


        def getRuleIndex(self):
            return MAS2JavaParser.RULE_agent

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAgent" ):
                listener.enterAgent(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAgent" ):
                listener.exitAgent(self)




    def agent(self):

        localctx = MAS2JavaParser.AgentContext(self, self._ctx, self.state)
        self.enterRule(localctx, 10, self.RULE_agent)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 59
            self.match(MAS2JavaParser.ID)
            self.state = 61
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAS2JavaParser.FILENAME:
                self.state = 60
                self.match(MAS2JavaParser.FILENAME)


            self.state = 64
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAS2JavaParser.T__11:
                self.state = 63
                self.agt_options()


            self.state = 67
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAS2JavaParser.T__13:
                self.state = 66
                self.agt_arch_class()


            self.state = 70
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAS2JavaParser.T__14:
                self.state = 69
                self.agt_belief_base_class()


            self.state = 73
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAS2JavaParser.T__15:
                self.state = 72
                self.agt_class()


            self.state = 77
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAS2JavaParser.T__9:
                self.state = 75
                self.match(MAS2JavaParser.T__9)
                self.state = 76
                self.match(MAS2JavaParser.NUMBER)


            self.state = 80
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAS2JavaParser.T__7:
                self.state = 79
                self.agt_at()


            self.state = 82
            self.match(MAS2JavaParser.T__10)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class Agt_optionsContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return MAS2JavaParser.RULE_agt_options

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAgt_options" ):
                listener.enterAgt_options(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAgt_options" ):
                listener.exitAgt_options(self)




    def agt_options(self):

        localctx = MAS2JavaParser.Agt_optionsContext(self, self._ctx, self.state)
        self.enterRule(localctx, 12, self.RULE_agt_options)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 84
            self.match(MAS2JavaParser.T__11)
            self.state = 88
            self._errHandler.sync(self)
            _alt = self._interp.adaptivePredict(self._input,12,self._ctx)
            while _alt!=1 and _alt!=ATN.INVALID_ALT_NUMBER:
                if _alt==1+1:
                    self.state = 85
                    self.matchWildcard() 
                self.state = 90
                self._errHandler.sync(self)
                _alt = self._interp.adaptivePredict(self._input,12,self._ctx)

            self.state = 91
            self.match(MAS2JavaParser.T__12)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class Agt_arch_classContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def ID(self):
            return self.getToken(MAS2JavaParser.ID, 0)

        def getRuleIndex(self):
            return MAS2JavaParser.RULE_agt_arch_class

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAgt_arch_class" ):
                listener.enterAgt_arch_class(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAgt_arch_class" ):
                listener.exitAgt_arch_class(self)




    def agt_arch_class(self):

        localctx = MAS2JavaParser.Agt_arch_classContext(self, self._ctx, self.state)
        self.enterRule(localctx, 14, self.RULE_agt_arch_class)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 93
            self.match(MAS2JavaParser.T__13)
            self.state = 94
            self.match(MAS2JavaParser.ID)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class Agt_belief_base_classContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def ID(self):
            return self.getToken(MAS2JavaParser.ID, 0)

        def getRuleIndex(self):
            return MAS2JavaParser.RULE_agt_belief_base_class

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAgt_belief_base_class" ):
                listener.enterAgt_belief_base_class(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAgt_belief_base_class" ):
                listener.exitAgt_belief_base_class(self)




    def agt_belief_base_class(self):

        localctx = MAS2JavaParser.Agt_belief_base_classContext(self, self._ctx, self.state)
        self.enterRule(localctx, 16, self.RULE_agt_belief_base_class)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 96
            self.match(MAS2JavaParser.T__14)
            self.state = 97
            self.match(MAS2JavaParser.ID)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class Agt_classContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def ID(self):
            return self.getToken(MAS2JavaParser.ID, 0)

        def getRuleIndex(self):
            return MAS2JavaParser.RULE_agt_class

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAgt_class" ):
                listener.enterAgt_class(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAgt_class" ):
                listener.exitAgt_class(self)




    def agt_class(self):

        localctx = MAS2JavaParser.Agt_classContext(self, self._ctx, self.state)
        self.enterRule(localctx, 18, self.RULE_agt_class)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 99
            self.match(MAS2JavaParser.T__15)
            self.state = 100
            self.match(MAS2JavaParser.ID)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class Agt_atContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def ID(self):
            return self.getToken(MAS2JavaParser.ID, 0)

        def getRuleIndex(self):
            return MAS2JavaParser.RULE_agt_at

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterAgt_at" ):
                listener.enterAgt_at(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitAgt_at" ):
                listener.exitAgt_at(self)




    def agt_at(self):

        localctx = MAS2JavaParser.Agt_atContext(self, self._ctx, self.state)
        self.enterRule(localctx, 20, self.RULE_agt_at)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 102
            self.match(MAS2JavaParser.T__7)
            self.state = 103
            self.match(MAS2JavaParser.ID)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx





