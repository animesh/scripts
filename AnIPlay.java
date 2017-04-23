package LUDOSimulator;

import java.util.Random;
import java.util.Hashtable;

public class AnIPlay implements LUDOPlayer {

	LUDOBoard board;
	Random rand;
	int playCnter;
	Hashtable moveTable = new Hashtable();
	Double change = 0.05;

	public AnIPlay(LUDOBoard board) {
		this.board = board;
		rand = new Random();
		playCnter = 0;
		moveTable.put(0, 1 / 6.0);
		moveTable.put(1, 1 / 6.0);
		moveTable.put(2, 1 / 6.0);
		moveTable.put(3, 1 / 6.0);
		moveTable.put(4, 1 / 6.0);
		moveTable.put(5, 1 / 6.0);
	}

	public void reward() {
		moveTable.put(0, (Double) moveTable.get(0) - change);
		moveTable.put(1, (Double) moveTable.get(1) + change);
		moveTable.put(2, (Double) moveTable.get(2) - change);
		moveTable.put(3, (Double) moveTable.get(3) + change);
		moveTable.put(4, (Double) moveTable.get(4) - change);
		moveTable.put(5, (Double) moveTable.get(5) + change);
	}

	public void play() {
		board.print("AnIPlay");
		board.rollDice();
		float nrmx = -1;
		int nrbest = -1;

		for (int i = 0; i < 4; i++) {
			float value = analyzeBrickSituation(i);
			rand = new Random();
			Double sum = 0.0;
			Double prob = rand.nextDouble();
			for (int j = 0; j < 6; j++) {
				sum += (Double) moveTable.get(j);
				if (prob < sum && value > nrmx && value > 0) {
					nrbest = i;
					nrmx = value;
				}
			}
		}

		switch ((int) nrmx) {
		case 0:board.moveBrick(nrbest);break;
		case 1:board.moveBrick(nrbest);reward();break;
		case 2:board.moveBrick(nrbest);break;
		case 3:board.moveBrick(nrbest);reward();break;
		case 4:board.moveBrick(nrbest);break;
		case 5:board.moveBrick(nrbest);reward();break;
		}
	}

	public float analyzeBrickSituation(int i) {
		if (board.moveable(i)) {
			int[][] current_board = board.getBoardState();
			int[][] new_board = board.getNewBoardState(i, board.getMyColor(),
					board.getDice());
			if (hitOpponentHome(current_board, new_board)) {
				return 5;
			} else if (hitMySelfHome(current_board, new_board)) {
				return 0;
			} else if (board.isStar(new_board[board.getMyColor()][i])) {
				return 4;
			} else if (moveOut(current_board, new_board)) {
				return 3;
			} else if (board.atHome(new_board[board.getMyColor()][i], board.getMyColor())) {
				return 2;
			} else {return 1;}
		} else {return 0;}
	}

	private boolean moveOut(int[][] current_board, int[][] new_board) {
		for (int i = 0; i < 4; i++) {
			if (board.inStartArea(current_board[board.getMyColor()][i], board.getMyColor())
					&& !board.inStartArea(new_board[board.getMyColor()][i],board.getMyColor())) {
				return true;
			}
		}
		return false;
	}

	private boolean hitOpponentHome(int[][] current_board, int[][] new_board) {
		for (int i = 0; i < 4; i++) {
			for (int j = 0; j < 4; j++) {
				if (board.getMyColor() != i) {
					if (board.atField(current_board[i][j])
							&& !board.atField(new_board[i][j])) {
						return true;
					}
				}
			}
		}
		return false;
	}

	private boolean hitMySelfHome(int[][] current_board, int[][] new_board) {
		for (int i = 0; i < 4; i++) {
			if (!board.inStartArea(current_board[board.getMyColor()][i], board
					.getMyColor())
					&& board.inStartArea(new_board[board.getMyColor()][i],
							board.getMyColor())) {
				return true;
			}
		}
		return false;
	}
}
