from dataclasses import dataclass

from .mas2j.MAS2JavaListener import MAS2JavaListener
from .mas2j.MAS2JavaParser import MAS2JavaParser


@dataclass
class Agent:
    name: str
    filename: str
    count: int


class Mas2fpGenerator(MAS2JavaListener):
    def __init__(self):
        super().__init__()

        self._output = ""
        self._name = ""
        self._agent = None

    @property
    def output(self) -> str:
        return self._output

    @property
    def agent(self) -> Agent:
        return self._agent

    def enterMas(self, ctx:MAS2JavaParser.MasContext):
        self._name = ctx.ID().getText()

    def enterAgent(self, ctx:MAS2JavaParser.AgentContext):
        if self._agent:
            raise Exception("Only one agent is supported for now")

        agent_name = ctx.ID().getText()
        agent_count = ctx.NUMBER()
        agent_count = 1 if agent_count is None else int(ctx.NUMBER().getText())

        agent_filename = ctx.FILENAME()
        if agent_filename is None:
            agent_filename = agent_name + ".fap"
        else:
            agent_filename = agent_filename.getText().replace(".asl", ".fap")

        if agent_count > 1:
            raise Exception("Only one agent is supported for now")

        self._agent = Agent(agent_name, agent_filename, agent_count)

    def exitAgent(self, ctx:MAS2JavaParser.AgentContext):
        agent = self._agent
        self._output = f'load("{self._name}","{agent.filename}",{agent.count}).\n'

    def enterInfrastructure(self, ctx:MAS2JavaParser.InfrastructureContext):
        infrastructure = ctx.ID().symbol.text
        if infrastructure != "Centralised":
            raise Exception("Only Centralised infrastructure is supported")

    def enterEnvironment(self, ctx:MAS2JavaParser.EnvironmentContext):
        raise Exception("Environment is not supported")

    def enterExec_control(self, ctx:MAS2JavaParser.Exec_controlContext):
        raise Exception("Exec_control is not supported")

    def enterAgt_options(self, ctx:MAS2JavaParser.Agt_optionsContext):
        raise Exception("Options are not supported")

    def enterAgt_arch_class(self, ctx:MAS2JavaParser.Agt_arch_classContext):
        raise Exception("agentArchClass is not supported")

    def enterAgt_at(self, ctx:MAS2JavaParser.Agt_atContext):
        raise Exception("at option is not supported")

    def enterAgt_class(self, ctx:MAS2JavaParser.Agt_classContext):
        raise Exception("agentClass is not supported")
