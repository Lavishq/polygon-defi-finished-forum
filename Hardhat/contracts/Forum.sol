//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

// We need to import either an interface or the contract itself
// so that our contract knows how to call the Token's functions
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Forum {
    struct Question {
        uint questionId;
        string message;
        address creatorAddress;
        uint timestamp;
    }

    struct Answer {
        uint answerId;
        uint questionId;
        address creatorAddress;
        string message;
        uint timestamp;
        uint upvotes;
    }

    Question[] public questions;
    Answer[] public answers;
    mapping(uint => uint[]) public answersPerQuestion;

    // Keeps track of which users have upvoted an answer
    // We use this to prevent a user from upvoting more than once
    mapping(uint => mapping(address => bool)) public upvoters;
    // Keeps track of how many upvotes the user has given
    // This could be used to reward "SUPER TIPPERS"
    mapping(address => uint) public usersUpvoteCount;

    event QuestionAdded(Question question);
    event AnswerAdded(Answer answer);
    event AnswerUpvoted(Answer answer);

    // Use the IERC20 interface as the variable's type.
    // We make it immutable so that it can be assigned
    // at constuction time but cannot be modified later
    IERC20 public immutable Goflow;
    // Internal variable for helping with token math
    uint constant decimals = 18;

    // It's better if we define the tip and participation amount as
    // state variables rather than within the function.
    // Also, don't forget we can't use floating-point numbers in solidity
    uint amountToPay = 1 * 10**decimals;
    uint amountToParticipate = 10 * 10**decimals;

    constructor(address _tokenAddress) {
        Goflow = IERC20(_tokenAddress);
    }

    // We created a modifier to avoid duplicating code.
    // We can add it to function declarations to check conditions
    // before continuing with the function, indicated by the _;
    modifier answerExists(uint _answerId) {
        require(answers.length >= _answerId, "Answer does not exist!");
        _;
    }

    function postQuestion(string calldata _message) external {
        uint questionCounter = questions.length;
        Question memory question = Question({
            questionId: questionCounter,
            message: _message,
            creatorAddress: msg.sender,
            timestamp: block.timestamp
        });
        questions.push(question);
        emit QuestionAdded(question);
    }

    function postAnswer(uint _questionId, string calldata _message) external {
        uint answerCounter = answers.length;
        Answer memory answer = Answer({
            answerId: answerCounter,
            questionId: _questionId,
            creatorAddress: msg.sender,
            message: _message,
            timestamp: block.timestamp,
            upvotes: 0
        });
        // we use an answer array and an answersPerQuestion mapping to store answerIds for each question.
        // This makes it easier for us to fetch the answers based on a questionId
        answers.push(answer);
        answersPerQuestion[_questionId].push(answerCounter);
        emit AnswerAdded(answer);
    }

    function upvoteAnswer(uint _answerId) external answerExists(_answerId) {
        Answer storage currentAnswer = answers[_answerId];

        require(
            upvoters[_answerId][msg.sender] != true,
            "User already upvoted this answer!"
        );
        require(
            answers[_answerId].creatorAddress != msg.sender,
            "Cannot upvote own answer!"
        );
        require(
            Goflow.balanceOf(msg.sender) >= amountToPay,
            "User has insufficient balance!"
        );
        require(
            Goflow.allowance(msg.sender, address(this)) >= amountToPay,
            "Account did not approve token succesfully!"
        );

        bool sent;
        if (
            Goflow.balanceOf(currentAnswer.creatorAddress) >=
            amountToParticipate
        ) {
            sent = Goflow.transferFrom(
                msg.sender,
                currentAnswer.creatorAddress,
                amountToPay
            );
        } else {
            sent = Goflow.transferFrom(msg.sender, address(this), amountToPay);
        }

        require(sent, "Token transfer failed!");
        currentAnswer.upvotes++;
        usersUpvoteCount[msg.sender]++;
        upvoters[_answerId][msg.sender] = true;
        emit AnswerUpvoted(currentAnswer);
    }

    function getQuestions() external view returns (Question[] memory) {
        return questions;
    }

    function getAnswersPerQuestion(uint _questionId)
        public
        view
        returns (uint[] memory)
    {
        return answersPerQuestion[_questionId];
    }

    function getUpvotes(uint _answerId)
        public
        view
        answerExists(_answerId)
        returns (uint)
    {
        return answers[_answerId].upvotes;
    }
}
