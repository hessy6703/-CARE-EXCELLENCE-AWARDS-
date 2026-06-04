<?php
/**
 * CEAMS - Authentication Controller
 */

namespace App\Controllers;

use App\Models\User;
use Core\Request;
use Core\Response;

class AuthController extends BaseController
{
    private $userModel;

    public function __construct()
    {
        parent::__construct();
        $this->userModel = new User();
    }

    /**
     * Show login form
     */
    public function login()
    {
        if ($this->auth) {
            Response::redirect('/dashboard');
        }
        $this->view('auth.login');
    }

    /**
     * Handle login
     */
    public function authenticate()
    {
        if (!Request::isPost()) {
            Response::redirect('/login');
        }

        $email = Request::sanitize(Request::post('email'));
        $password = Request::post('password');

        // Validation
        $errors = Request::validate(
            ['email' => $email, 'password' => $password],
            ['email' => 'required|email', 'password' => 'required']
        );

        if (!empty($errors)) {
            Response::flash('Invalid email or password', 'error');
            Response::redirect('/login');
        }

        // Find user
        $user = $this->userModel->findByEmail($email);

        if (!$user) {
            $this->logFailedAttempt($email);
            Response::flash('Invalid credentials', 'error');
            Response::redirect('/login');
        }

        // Check if account is active
        if ($user['status'] !== 'active') {
            Response::flash('Your account is inactive', 'error');
            Response::redirect('/login');
        }

        // Verify password
        if (!$this->userModel->verifyPassword($password, $user['password'])) {
            $this->logFailedAttempt($email);
            Response::flash('Invalid credentials', 'error');
            Response::redirect('/login');
        }

        // Successful login
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['user_email'] = $user['email'];
        $_SESSION['user_role'] = $user['role_id'];
        $_SESSION['logged_in'] = true;

        // Update last login
        $this->userModel->update($user['id'], [
            'last_login' => date('Y-m-d H:i:s')
        ]);

        // Log session
        $this->logSession($user['id'], 'login');

        Response::flash('Welcome back, ' . $user['first_name'], 'success');
        Response::redirect('/dashboard');
    }

    /**
     * Logout
     */
    public function logout()
    {
        if (isset($_SESSION['user_id'])) {
            $this->logSession($_SESSION['user_id'], 'logout');
        }

        session_destroy();
        Response::flash('You have been logged out', 'success');
        Response::redirect('/login');
    }

    /**
     * Show password recovery form
     */
    public function forgotPassword()
    {
        $this->view('auth.forgot-password');
    }

    /**
     * Handle password recovery
     */
    public function sendReset()
    {
        $email = Request::sanitize(Request::post('email'));

        $user = $this->userModel->findByEmail($email);

        if ($user) {
            $resetToken = bin2hex(random_bytes(32));
            // TODO: Store token in database and send email
            Response::flash('Password reset link sent to your email', 'success');
        } else {
            Response::flash('Email not found in our records', 'error');
        }

        Response::redirect('/forgot-password');
    }

    /**
     * Log failed login attempt
     */
    private function logFailedAttempt($email)
    {
        // TODO: Implement rate limiting and logging
    }

    /**
     * Log session activity
     */
    private function logSession($userId, $action)
    {
        // TODO: Implement session logging
    }
}
