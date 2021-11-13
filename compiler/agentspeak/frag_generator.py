from agentspeak.parser.AgentSpeakListener import AgentSpeakListener
from agentspeak.parser.AgentSpeakParser import AgentSpeakParser


class FragGenerator(AgentSpeakListener):
    def __init__(self):
        super().__init__()

        self._output = ""

    @property
    def output(self) -> str:
        return self._output

    def enterInit_bels(self, ctx:AgentSpeakParser.Init_belsContext):
        pass

    def enterInit_goals(self, ctx: AgentSpeakParser.Init_goalsContext):
        for literal in ctx.literal():
            formula = literal.atomic_formula()
            self._output += f"goal(ach,{formula.getText()},null,[[]],active).\n"

    def enterPlans(self, ctx:AgentSpeakParser.PlansContext):
        for plan in ctx.plan():
            triggering_event = plan.triggering_event()

            # TODO: add or remove + prefix
            event_name = triggering_event.getText()[2:]
            # if prefix := triggering_event.GOAL_PREFIX() and prefix != "!":
            #     raise Exception("For now, only achievement goals are supported")

            context_str = context.getText() if (context := plan.context()) else ""

            converted_body = []

            if body := plan.body():
                for body_formula in body.body_formula():
                    children_len = len(body_formula.children)
                    if children_len == 1:
                        child = body_formula.getChild(0)
                        if isinstance(child, AgentSpeakParser.Internal_actionContext):
                            if child.ATOM().getText() != "print":
                                raise Exception("For now, only print action is supported.")
                            converted_body.append(f"act({child.getText()[1:]})")
                        elif isinstance(child, AgentSpeakParser.Rel_exprContext):
                            converted_body.append(f"act({body_formula.getText()})")
                        else:
                            raise Exception("TODO")
                    elif children_len == 2:
                        prefix = body_formula.getChild(0)
                        if prefix.getText() != "!":
                            raise Exception("For now, only achievement goals are supported")
                        literal = body_formula.getChild(1)
                        converted_body.append(f"ach({literal.getText()})")
                    else:
                        raise Exception("TODO")

            body_str = "[" + ",".join(converted_body) + "]"

            self._output += f"plan(ach,{event_name},[{context_str}],{body_str}).\n"

    def exitAgent(self, ctx: AgentSpeakParser.AgentContext):
        print(self._output)
