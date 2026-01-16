"""
Author: Ondrej Misar
Description: Implementation of the external service that runs the different MCTS simulations.
             Based on the external architecture
"""

import json
import logging
import sys

import zmq
from loguru import logger

import MCTS_python.scheduler.mcts as mcts
import MCTS_python.scheduler.mcts_parallel as mcts_parallel
import MCTS_python.scheduler.mcts_online_learning as mcts_online_learning

logging.getLogger("swiplserver").setLevel(logging.CRITICAL + 1)

logger.remove()
logger.add(sys.stderr, level="INFO")


def zmq_service(port=5555):
    # Start the service
    context = zmq.Context()
    socket = context.socket(zmq.REP)
    socket.bind(f"tcp://*:{port}")
    logger.info(f"MCTS ZeroMQ service running on port {port}...")

    while True:
        try:
            # Receive the request
            message = socket.recv()
            params = json.loads(message.decode())
            program = params['program']
            environment = params['environment']
            expansions = params['expansions']
            simulation = params['simulation']
            steps = params['steps']
            mcts_type = params['type']
            environment_name = params["environment_name"]
            environment_path = params["environment_path"]

            logger.debug(f"service type received: {mcts_type}")

            mcts_sim = mcts_parallel.MCTS(program, environment, expansions, simulation, steps, environment_name,
                                          environment_path)

            # Initialize the selected MCTS variant
            if mcts_type == 'learning':
                mcts_sim = mcts_online_learning.MCTS(program, environment, expansions, simulation, steps,
                                                     environment_name,
                                                     environment_path)

            if mcts_type == 'basic_parallel':
                mcts_sim = mcts_parallel.MCTS(program, environment, expansions, simulation, steps, environment_name,
                                              environment_path)

            if mcts_type == 'basic_sequential':
                mcts_sim = mcts.MCTS(program, environment, expansions, simulation, steps, environment_name,
                                     environment_path)

            prefix, act = mcts_sim.run()
            act_prolog = act[0].deliberation if len(act) > 0 else ""
            prefix_prolog = prefix[0].deliberation if len(prefix) > 0 else ""

            # Send response
            response = {"prefix": prefix_prolog, "act": act_prolog}
            socket.send(json.dumps(response).encode())
        except Exception as e:
            error_response = {"error": str(e)}
            socket.send(json.dumps(error_response).encode())
            response = {"prefix": "", "act": ""}
            socket.send(json.dumps(response).encode())


if __name__ == '__main__':
    zmq_service(port=5555)
