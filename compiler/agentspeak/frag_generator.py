from .asl.AgentSpeakListener import AgentSpeakListener
from .asl.AgentSpeakParser import AgentSpeakParser

from .config import internal_functions, internal_functions_mapping


class FragGenerator(AgentSpeakListener):
    def __init__(self):
        super().__init__()

        self._output = ""

    @property
    def output(self) -> str:
        return self._output

    def enterBeliefs(self, ctx:AgentSpeakParser.BeliefsContext):
        for belief in ctx.literal():
            self._output += f"fact({belief.getText()}).\n"

    def enterRules(self, ctx:AgentSpeakParser.RulesContext):
        if ctx.children:
            raise Exception("Currently, beliefs rules are not supported.")

    def enterInit_goal(self, ctx:AgentSpeakParser.Init_goalContext):
        # TODO: other types!
        literal = ctx.literal()
        formula = literal.atomic_formula()
        self._output += f"goal(ach,{formula.getText()},null,[[]],active).\n"

    def enterPlan(self, ctx:AgentSpeakParser.PlanContext):
        triggering_event = ctx.triggering_event()

        # TODO: remove + prefix
        prefix_symbols = {"+", "!"}

        event_name = triggering_event.getText()
        event_prefix = ""
        for s in event_name:
            if s in prefix_symbols:
                event_prefix += s
            else:
                break

        event_name = event_name.removeprefix(event_prefix)

        _plan_types = {
            "+!": "ach",
            "+": "add",
        }

        plan_type = _plan_types.get(event_prefix)
        if plan_type is None:
            raise Exception(f"Unsupported plan type for prefix: {event_prefix}")

        context_str = context.getText() if (context := ctx.context()) else ""

        converted_body = []

        if body := ctx.body():
            for body_formula in body.body_formula():
                children_len = len(body_formula.children)
                if children_len == 1:
                    child = body_formula.getChild(0)
                    if isinstance(child, AgentSpeakParser.Internal_actionContext):
                        fcn_name = child.ATOM().getText()
                        fnc_call_str = child.getText()[1:]
                        if fcn_name not in internal_functions:
                            raise Exception(f"Currently, the internal {fcn_name} function is not supported.")

                        if fcn_prolog_name := internal_functions_mapping.get(fcn_name):
                            fnc_call_str = fnc_call_str.replace(fcn_name, fcn_prolog_name, 1)

                        converted_body.append(f"act({fnc_call_str})")
                    elif isinstance(child, AgentSpeakParser.Rel_exprContext):
                        converted_body.append(f"act({body_formula.getText()})")
                    else:
                        raise Exception("TODO")
                elif children_len == 2:
                    prefix = body_formula.getChild(0).getText()
                    literal = body_formula.getChild(1)
                    if prefix == "!":
                        predicate = "ach"
                    elif prefix == "+":
                        predicate = "add"
                    elif prefix == "?":
                        predicate = "test"
                    else:
                        raise Exception(
                            "Currently, only achievement goals, test goals and add belief operation are supported"
                        )

                    converted_body.append(f"{predicate}({literal.getText()})")
                else:
                    raise Exception("TODO")

        body_str = "[" + ",".join(converted_body) + "]"

        self._output += f"plan({plan_type},{event_name},[{context_str}],{body_str}).\n"

    def exitAgent(self, ctx: AgentSpeakParser.AgentContext):
        print(self._output)
