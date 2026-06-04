<?php
/**
 * CEAMS - User Model
 */

namespace App\Models;

class User extends BaseModel
{
    protected $table = 'users';
    protected $fillable = ['email', 'password', 'first_name', 'last_name', 'department_id', 'role_id', 'status'];

    /**
     * Find user by email
     */
    public function findByEmail($email)
    {
        return $this->findBy('email', $email);
    }

    /**
     * Find user by employee ID
     */
    public function findByEmployeeId($employeeId)
    {
        return $this->findBy('employee_id', $employeeId);
    }

    /**
     * Get users by department
     */
    public function getByDepartment($departmentId)
    {
        $sql = "SELECT * FROM {$this->table} WHERE department_id = :dept_id AND status = 'active'";
        $this->db->query($sql);
        $this->db->bind(':dept_id', $departmentId);
        return $this->db->resultSet();
    }

    /**
     * Get users by role
     */
    public function getByRole($roleId)
    {
        $sql = "SELECT * FROM {$this->table} WHERE role_id = :role_id AND status = 'active'";
        $this->db->query($sql);
        $this->db->bind(':role_id', $roleId);
        return $this->db->resultSet();
    }

    /**
     * Hash password
     */
    public function hashPassword($password)
    {
        return password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    }

    /**
     * Verify password
     */
    public function verifyPassword($password, $hash)
    {
        return password_verify($password, $hash);
    }
}
